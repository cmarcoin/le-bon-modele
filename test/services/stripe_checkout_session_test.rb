require "test_helper"

class StripeCheckoutSessionTest < ActiveSupport::TestCase
  setup do
    @pack = Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier le modele",
      description: "Description",
      price_cents: 5_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/starter-pack.svg",
      accent_class: "text-brand-accent",
      stripe_product_id: "prod_test",
      stripe_price_id: "price_test"
    )
    @slot = AvailabilitySlot.create!(
      pack: @pack,
      starts_at: 2.days.from_now.change(hour: 10),
      ends_at: 2.days.from_now.change(hour: 10, min: 45),
      timezone: "Europe/Paris"
    )
    @user = User.create!(
      email: "buyer@example.com",
      name: "Buyer Test",
      password: "password123456",
      role: "client"
    )
    @booking = Booking.create!(
      user: @user,
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Buyer Test",
      customer_email: "buyer@example.com",
      customer_phone: "0600000000",
      amount_cents: @pack.price_cents,
      currency: @pack.currency,
      status: "pending_payment"
    )
    captured_params = nil
    @original_create = Stripe::Checkout::Session.method(:create)
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      captured_params = params
      Struct.new(:id, :url).new("cs_test_123", "https://checkout.stripe.test/session")
    end
    @captured_params_ref = -> { captured_params }
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"
  end

  teardown do
    Stripe::Checkout::Session.define_singleton_method(:create, @original_create)
    ENV.delete("STRIPE_SECRET_KEY")
  end

  test "creates checkout session with stripe tax settings" do
    StripeCheckoutSession.create_for(@booking, "http://localhost:3001")
    captured_params = @captured_params_ref.call

    assert_equal "fr", captured_params[:locale]
    assert_equal "buyer@example.com", captured_params[:customer_email]
    assert_equal "always", captured_params[:customer_creation]
    assert_equal [ "card" ], captured_params[:payment_method_types]
    assert_equal "required", captured_params[:billing_address_collection]
    assert_nil captured_params[:shipping_address_collection]
    assert_equal({ enabled: true }, captured_params[:automatic_tax])
    assert captured_params[:expires_at].present?
    assert captured_params[:expires_at] > Time.current.to_i

    line_item = captured_params[:line_items].first
    assert_equal 1, line_item[:quantity]
    assert_equal "price_test", line_item[:price]
  end

  test "reuses open checkout session url" do
    open_session = Struct.new(:id, :url, :status, :expires_at, keyword_init: true).new(
      id: "cs_test_123",
      url: "https://checkout.stripe.test/open",
      status: "open",
      expires_at: 30.minutes.from_now.to_i
    )
    @booking.update!(stripe_checkout_session_id: "cs_test_123")

    Stripe::Checkout::Session.define_singleton_method(:retrieve) { |_id| open_session }

    url = StripeCheckoutSession.checkout_url_for(@booking, "http://localhost:3001")
    assert_equal "https://checkout.stripe.test/open", url
  end

  test "creates new checkout session when previous one expired" do
    expired_session = Struct.new(:id, :url, :status, :expires_at, :to_h, keyword_init: true).new(
      id: "cs_test_old",
      url: "https://checkout.stripe.test/old",
      status: "expired",
      expires_at: 1.hour.ago.to_i,
      to_h: { id: "cs_test_old", status: "expired" }
    )
    @booking.update!(stripe_checkout_session_id: "cs_test_old")
    PaymentTransaction.create!(
      booking: @booking,
      user: @user,
      pack: @pack,
      amount_cents: @pack.price_cents,
      currency: "eur",
      stripe_checkout_session_id: "cs_test_old"
    )

    Stripe::Checkout::Session.define_singleton_method(:retrieve) { |_id| expired_session }

    url = StripeCheckoutSession.checkout_url_for(@booking, "http://localhost:3001")

    assert_equal "https://checkout.stripe.test/session", url
    assert_equal "cs_test_123", @booking.reload.stripe_checkout_session_id
    assert_equal "cs_test_123", @booking.payment_transaction.stripe_checkout_session_id
  end

  test "raises when pack is not synced with stripe" do
    @pack.update!(stripe_product_id: nil, stripe_price_id: nil)

    error = assert_raises(StripeCheckoutSession::ConfigurationError) do
      StripeCheckoutSession.create_for(@booking, "http://localhost:3001")
    end

    assert_match(/synchronisé/, error.message)
  end
end
