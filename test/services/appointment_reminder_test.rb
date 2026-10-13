require "test_helper"

class AppointmentReminderTest < ActiveSupport::TestCase
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
      starts_at: 12.hours.from_now,
      ends_at: 12.hours.from_now + 45.minutes,
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
      paid_at: 3.hours.ago
    )
  end

  test "sends one reminder for a paid booking inside the next day" do
    assert_enqueued_emails 1 do
      assert_equal 1, AppointmentReminder.call
    end

    assert_not_nil @booking.reload.appointment_reminder_sent_at
  end

  test "does not remind twice" do
    @booking.update!(appointment_reminder_sent_at: 1.hour.ago)

    assert_no_enqueued_emails do
      assert_equal 0, AppointmentReminder.call
    end
  end

  test "does not remind for a booking just paid" do
    @booking.update!(paid_at: 10.minutes.ago)

    assert_no_enqueued_emails do
      assert_equal 0, AppointmentReminder.call
    end
  end

  test "does not remind more than 24 hours ahead" do
    @slot.update!(starts_at: 3.days.from_now, ends_at: 3.days.from_now + 45.minutes)

    assert_no_enqueued_emails do
      assert_equal 0, AppointmentReminder.call
    end
  end
end
