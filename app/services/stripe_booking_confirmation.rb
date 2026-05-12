class StripeBookingConfirmation
  def self.confirm_from_session!(session)
    new(session).confirm!
  end

  def initialize(session)
    @session = session
  end

  def confirm!
    return unless session.payment_status == "paid"

    booking = Booking.find_by!(stripe_checkout_session_id: session.id)
    payment_transaction = booking.payment_transaction

    Booking.transaction do
      booking.update!(status: "paid", paid_at: Time.current)
      payment_transaction.update!(
        status: "paid",
        stripe_payment_intent_id: session.payment_intent,
        tax_amount_cents: tax_amount_cents,
        stripe_payload: session.to_h
      )
    end

    BookingMailer.confirmation(booking).deliver_later
    BookingMailer.admin_notification(booking).deliver_later
    booking
  end

  private

  attr_reader :session

  def tax_amount_cents
    details = session.respond_to?(:total_details) ? session.total_details : session[:total_details]
    return 0 if details.blank?

    details.respond_to?(:amount_tax) ? details.amount_tax.to_i : details[:amount_tax].to_i
  end
end
