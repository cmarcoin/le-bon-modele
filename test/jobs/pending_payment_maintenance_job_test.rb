require "test_helper"

class PendingPaymentMaintenanceJobTest < ActiveJob::TestCase
  test "runs sync and reminders" do
    with_stubbed_maintenance_services(
      sync_result: PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 0, unchanged_count: 0),
      reminder_count: 0
    ) do
      assert_nothing_raised do
        PendingPaymentMaintenanceJob.perform_now
      end
    end
  end

  test "notifies admin when bookings are canceled" do
    result = PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 2, unchanged_count: 1)

    with_stubbed_maintenance_services(sync_result: result, reminder_count: 0) do
      assert_enqueued_emails 1 do
        PendingPaymentMaintenanceJob.perform_now
      end
    end
  end

  private

  def with_stubbed_maintenance_services(sync_result:, reminder_count:)
    original_sync = PendingPaymentBookingSync.method(:call)
    original_reminder = PendingPaymentBookingReminder.method(:call)

    PendingPaymentBookingSync.define_singleton_method(:call) { sync_result }
    PendingPaymentBookingReminder.define_singleton_method(:call) { reminder_count }

    yield
  ensure
    PendingPaymentBookingSync.singleton_class.define_method(:call, original_sync)
    PendingPaymentBookingReminder.singleton_class.define_method(:call, original_reminder)
  end
end
