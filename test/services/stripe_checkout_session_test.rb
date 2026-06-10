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
      accent_class: "text-brand-accent"
    )
    @slot = AvailabilitySlot.create!(
      pack: @pack,
      starts_at: 2.days.from_now.change(hour: 10),
      ends_at: 2.days.from_now.change(hour: 10, min: 45),
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "charles.marcoin@gmail.com"
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
    @captured_params = nil
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

  test "creates checkout session with french vat settings" do
    StripeCheckoutSession.create_for(@booking, "http://localhost:3001")
    captured_params = @captured_params_ref.call

    assert_equal "fr", captured_params[:locale]
    assert_equal "always", captured_params[:customer_creation]
    assert_equal "required", captured_params[:billing_address_collection]
    assert_nil captured_params[:customer_update]
    assert_equal({ enabled: true }, captured_params[:automatic_tax])

    line_item = captured_params[:line_items].first
    assert_equal "inclusive", line_item[:price_data][:tax_behavior]
    assert_equal StripeCheckoutSession::CONSULTING_TAX_CODE, line_item[:price_data][:product_data][:tax_code]
  end
end
