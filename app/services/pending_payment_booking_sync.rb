class PendingPaymentBookingSync
  Result = Struct.new(:confirmed_count, :canceled_count, :unchanged_count, keyword_init: true)

  def self.call
    new.call
  end

  def self.sync_booking(booking)
    new.sync_booking(booking)
  end

  def call
    confirmed_count = 0
    canceled_count = 0
    unchanged_count = 0

    Booking.pending_payment.includes(:payment_transaction, :pack, :availability_slot).find_each do |booking|
      case sync_booking(booking)
      when :confirmed then confirmed_count += 1
      when :canceled then canceled_count += 1
      else unchanged_count += 1
      end
    end

    Result.new(
      confirmed_count: confirmed_count,
      canceled_count: canceled_count,
      unchanged_count: unchanged_count
    )
  end

  def sync_booking(booking)
    return :unchanged if booking.stripe_checkout_session_id.blank?

    session = Stripe::Checkout::Session.retrieve(booking.stripe_checkout_session_id)

    if session.payment_status == "paid"
      StripeBookingConfirmation.confirm_from_session!(session)
      :confirmed
    elsif session.status == "expired" || session_expired?(session)
      booking.cancel_reservation!
      booking.payment_transaction&.update!(stripe_payload: session.to_h)
      :canceled
    else
      :unchanged
    end
  rescue Stripe::StripeError => error
    Rails.logger.warn("Pending payment sync skipped for booking #{booking.id}: #{error.message}")
    :unchanged
  end

  private

  def session_expired?(session)
    expires_at = session.respond_to?(:expires_at) ? session.expires_at : session[:expires_at]
    expires_at.present? && Time.zone.at(expires_at) <= Time.current
  end
end
