class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform
    count = AppointmentReminder.call
    Rails.logger.info("Appointment reminders sent: #{count}")
  end
end
