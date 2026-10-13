class AppointmentReminder
  def self.call
    new.call
  end

  def call
    sent_count = 0

    Booking.due_for_appointment_reminder.includes(:pack, :availability_slot).find_each do |booking|
      BookingMailer.appointment_reminder(booking).deliver_later
      booking.update!(appointment_reminder_sent_at: Time.current)
      sent_count += 1
    end

    sent_count
  end
end
