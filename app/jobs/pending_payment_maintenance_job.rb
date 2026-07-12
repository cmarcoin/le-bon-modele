class PendingPaymentMaintenanceJob < ApplicationJob
  queue_as :default

  def perform
    sync_result = PendingPaymentBookingSync.call
    reminder_count = PendingPaymentBookingReminder.call

    Rails.logger.info(
      "Pending payment maintenance: confirmed=#{sync_result.confirmed_count} " \
      "canceled=#{sync_result.canceled_count} unchanged=#{sync_result.unchanged_count} " \
      "reminders=#{reminder_count}"
    )

    if sync_result.canceled_count.positive?
      BookingMailer.admin_pending_payment_cleanup(sync_result).deliver_later
    end
  end
end
