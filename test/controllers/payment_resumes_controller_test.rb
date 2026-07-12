require "test_helper"

class PaymentResumesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pack = Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier",
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
    @booking = Booking.create!(
      user: users(:client),
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Client Test",
      customer_email: "client@example.com",
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "pending_payment",
      stripe_checkout_session_id: "cs_resume_open"
    )
    PaymentTransaction.create!(
      booking: @booking,
      user: users(:client),
      pack: @pack,
      amount_cents: @pack.price_cents,
      currency: "eur",
      stripe_checkout_session_id: "cs_resume_open"
    )
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"
  end

  teardown do
    ENV.delete("STRIPE_SECRET_KEY")
  end

  test "redirects to open stripe checkout session" do
    open_session = Struct.new(:id, :url, :status, :expires_at, :to_h, keyword_init: true).new(
      id: "cs_resume_open",
      url: "https://checkout.stripe.test/resume",
      status: "open",
      expires_at: 30.minutes.from_now.to_i,
      to_h: { id: "cs_resume_open", status: "open" }
    )
    Stripe::Checkout::Session.define_singleton_method(:retrieve) { |_id| open_session }

    get resume_payment_path(token: @booking.payment_resume_token)

    assert_redirected_to "https://checkout.stripe.test/resume"
  end

  test "rejects invalid token" do
    get resume_payment_path(token: "invalid-token")

    assert_redirected_to root_path
    assert_equal "Lien de paiement invalide ou expiré.", flash[:alert]
  end

  test "redirects paid bookings to success page" do
    @booking.update!(status: "paid", paid_at: Time.current)

    get resume_payment_path(token: @booking.payment_resume_token)

    assert_redirected_to checkout_success_path(session_id: "cs_resume_open")
  end
end
