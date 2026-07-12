require "test_helper"

class AvailabilitySlotPastPurgerTest < ActiveSupport::TestCase
  setup do
    @pack = Pack.create!(
      slug: "pack-purge-test",
      name: "Pack Purge",
      objective: "Test",
      description: "Description",
      price_cents: 29_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/pack-premium.svg",
      accent_class: "text-brand-coral"
    )
    @client = users(:client)
  end

  test "deletes past unbooked slots" do
    past_slot = create_slot(starts_at: 2.days.ago.change(hour: 10))
    future_slot = create_slot(starts_at: 2.days.from_now.change(hour: 10))

    result = AvailabilitySlotPastPurger.new.call

    assert_equal 1, result.deleted_count
    assert_not AvailabilitySlot.exists?(past_slot.id)
    assert AvailabilitySlot.exists?(future_slot.id)
  end

  test "skips past booked slots" do
    past_slot = create_slot(starts_at: 2.days.ago.change(hour: 11))
    Booking.create!(
      user: @client,
      pack: @pack,
      availability_slot: past_slot,
      customer_name: "Client Test",
      customer_email: @client.email,
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "paid"
    )

    result = AvailabilitySlotPastPurger.new.call

    assert_equal 0, result.deleted_count
    assert AvailabilitySlot.exists?(past_slot.id)
  end

  test "deletes past slots with canceled bookings" do
    past_slot = create_slot(starts_at: 2.days.ago.change(hour: 12))
    booking = Booking.create!(
      user: @client,
      pack: @pack,
      availability_slot: past_slot,
      customer_name: "Client Test",
      customer_email: @client.email,
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "canceled"
    )
    PaymentTransaction.create!(
      booking: booking,
      user: @client,
      pack: @pack,
      amount_cents: booking.amount_cents,
      currency: "eur",
      status: "canceled",
      stripe_checkout_session_id: "cs_test_purge_#{booking.id}",
      tax_amount_cents: 0
    )

    result = AvailabilitySlotPastPurger.new.call

    assert_equal 1, result.deleted_count
    assert_not AvailabilitySlot.exists?(past_slot.id)
    assert_not Booking.exists?(booking.id)
  end

  private

  def create_slot(starts_at:)
    AvailabilitySlot.create!(
      starts_at: starts_at,
      ends_at: starts_at + 45.minutes,
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "contact@lebonmodele.fr",
      pack: @pack,
      active: true
    )
  end
end
