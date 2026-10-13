require "test_helper"

class BookingCancellationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

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
      accent_class: "text-brand-accent"
    )
    @slot = AvailabilitySlot.create!(
      pack: @pack,
      starts_at: 4.days.from_now.change(hour: 10),
      ends_at: 4.days.from_now.change(hour: 10, min: 45),
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
      status: "paid",
      paid_at: 1.day.ago,
      stripe_checkout_session_id: "cs_customer_cancel"
    )
    PaymentTransaction.create!(
      booking: @booking,
      user: users(:client),
      pack: @pack,
      amount_cents: @booking.amount_cents,
      currency: "eur",
      status: "paid",
      stripe_checkout_session_id: "cs_customer_cancel",
      stripe_payment_intent_id: "pi_customer_cancel",
      tax_amount_cents: 0
    )
  end

  test "shows a refund when the appointment is more than 48 hours away" do
    get cancel_booking_path(token: @booking.cancellation_token)

    assert_response :success
    assert_match(/sera remboursée intégralement/, response.body)
  end

  test "customer cancellation refunds and frees the slot" do
    original_refund = Stripe::Refund.method(:create)
    Stripe::Refund.define_singleton_method(:create) { |*_args| Struct.new(:id).new("re_customer") }

    assert_enqueued_emails 2 do
      post cancel_booking_path(token: @booking.cancellation_token)
    end

    assert_redirected_to cancel_booking_path(token: @booking.cancellation_token)
    assert_equal "canceled", @booking.reload.status
    assert_equal "refunded", @booking.payment_transaction.reload.status
    assert_includes AvailabilitySlot.available_for(@pack), @slot
  ensure
    Stripe::Refund.define_singleton_method(:create, original_refund)
  end

  test "rejects an invalid cancellation link" do
    get cancel_booking_path(token: "not-a-token")

    assert_redirected_to root_path
    assert_equal "Lien d'annulation invalide ou expiré.", flash[:alert]
  end
end
