require "test_helper"

class PendingPaymentBookingReminderTest < ActiveSupport::TestCase
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
      stripe_checkout_session_id: "cs_reminder",
      created_at: 2.hours.ago
    )
  end

  test "sends reminder for due pending bookings" do
    assert_enqueued_emails 1 do
      sent_count = PendingPaymentBookingReminder.call
      assert_equal 1, sent_count
    end

    assert_not_nil @booking.reload.payment_reminder_sent_at
  end

  test "does not send reminder twice" do
    @booking.update!(payment_reminder_sent_at: 30.minutes.ago)

    assert_no_enqueued_emails do
      assert_equal 0, PendingPaymentBookingReminder.call
    end
  end

  test "does not send reminder for recent bookings" do
    @booking.update!(created_at: 10.minutes.ago)

    assert_no_enqueued_emails do
      assert_equal 0, PendingPaymentBookingReminder.call
    end
  end
end
