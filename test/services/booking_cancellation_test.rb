require "test_helper"

class BookingCancellationTest < ActiveSupport::TestCase
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
    @original_refund = Stripe::Refund.method(:create)
    Stripe::Refund.define_singleton_method(:create) { |*_args| Struct.new(:id).new("re_cancel_test") }
  end

  teardown do
    Stripe::Refund.define_singleton_method(:create, @original_refund)
  end

  test "refunds a paid booking more than 48 hours before the appointment" do
    booking = create_paid_booking(starts_at: 4.days.from_now)

    assert_enqueued_emails 2 do
      result = BookingCancellation.call(booking, refund: :auto, notify: true)
      assert_equal :canceled, result.outcome
      assert result.refunded
    end

    assert_equal "canceled", booking.reload.status
    assert_equal "refunded", booking.payment_transaction.reload.status
    assert_equal "re_cancel_test", booking.payment_transaction.stripe_refund_id
    assert_not_nil booking.canceled_at
  end

  test "cancels without refund inside 48 hours" do
    booking = create_paid_booking(starts_at: 12.hours.from_now)

    result = BookingCancellation.call(booking, refund: :auto, notify: true)

    assert_equal :canceled, result.outcome
    assert_not result.refunded
    assert_equal "canceled", booking.reload.status
    assert_equal "paid", booking.payment_transaction.reload.status
  end

  test "forces a refund inside 48 hours" do
    booking = create_paid_booking(starts_at: 12.hours.from_now)

    result = BookingCancellation.call(booking, refund: :force, notify: true)

    assert result.refunded
    assert_equal "refunded", booking.payment_transaction.reload.status
    assert_equal "canceled", booking.reload.status
  end

  private

  def create_paid_booking(starts_at:)
    slot = AvailabilitySlot.create!(
      pack: @pack,
      starts_at: starts_at,
      ends_at: starts_at + 45.minutes,
      timezone: "Europe/Paris"
    )
    booking = Booking.create!(
      user: users(:client),
      pack: @pack,
      availability_slot: slot,
      customer_name: "Client Test",
      customer_email: "client@example.com",
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "paid",
      paid_at: 3.days.ago,
      stripe_checkout_session_id: "cs_cancel_#{SecureRandom.hex(4)}"
    )
    PaymentTransaction.create!(
      booking: booking,
      user: users(:client),
      pack: @pack,
      amount_cents: booking.amount_cents,
      currency: "eur",
      status: "paid",
      stripe_checkout_session_id: booking.stripe_checkout_session_id,
      stripe_payment_intent_id: "pi_#{booking.id}",
      tax_amount_cents: 0
    )
    booking
  end
end
