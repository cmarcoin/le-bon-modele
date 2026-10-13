require "test_helper"

class PendingPaymentMaintenanceJobTest < ActiveJob::TestCase
  test "runs pending payment sync" do
    original_sync = PendingPaymentBookingSync.method(:call)
    PendingPaymentBookingSync.define_singleton_method(:call) do
      PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 0, unchanged_count: 0)
    end

    assert_nothing_raised do
      PendingPaymentMaintenanceJob.perform_now
    end
  ensure
    PendingPaymentBookingSync.singleton_class.define_method(:call, original_sync)
  end

  test "notifies admin when bookings are canceled" do
    original_sync = PendingPaymentBookingSync.method(:call)
    PendingPaymentBookingSync.define_singleton_method(:call) do
      PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 2, unchanged_count: 1)
    end

    assert_enqueued_emails 1 do
      PendingPaymentMaintenanceJob.perform_now
    end
  ensure
    PendingPaymentBookingSync.singleton_class.define_method(:call, original_sync)
  end
end
