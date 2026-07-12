class PendingPaymentBookingReminder
  def self.call
    new.call
  end

  def call
    sent_count = 0

    Booking.due_for_payment_reminder.includes(:pack, :availability_slot).find_each do |booking|
      next if booking.stripe_checkout_session_id.blank?

      BookingMailer.payment_reminder(booking).deliver_later
      booking.update!(payment_reminder_sent_at: Time.current)
      sent_count += 1
    end

    sent_count
  end
end
