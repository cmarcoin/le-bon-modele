require "test_helper"

class PendingPaymentMaintenanceJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "runs sync and reminders" do
    PendingPaymentBookingSync.stub(:call, PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 0, unchanged_count: 0)) do
      PendingPaymentBookingReminder.stub(:call, 0) do
        assert_nothing_raised do
          PendingPaymentMaintenanceJob.perform_now
        end
      end
    end
  end

  test "notifies admin when bookings are canceled" do
    result = PendingPaymentBookingSync::Result.new(confirmed_count: 0, canceled_count: 2, unchanged_count: 1)

    PendingPaymentBookingSync.stub(:call, result) do
      PendingPaymentBookingReminder.stub(:call, 0) do
        assert_enqueued_emails 1 do
          PendingPaymentMaintenanceJob.perform_now
        end
      end
    end
  end
end
