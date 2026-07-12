require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
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
      status: "pending_payment"
    )
    @transaction = PaymentTransaction.create!(
      booking: @booking,
      user: users(:client),
      pack: @pack,
      amount_cents: @pack.price_cents,
      currency: "eur",
      stripe_checkout_session_id: "cs_cancel_test"
    )
  end

  test "cancel uses cancel_reservation and cancels payment transaction" do
    get checkout_cancel_path(booking_id: @booking.id)

    assert_response :success
    assert_equal "canceled", @booking.reload.status
    assert_equal "canceled", @transaction.reload.status
  end
end
