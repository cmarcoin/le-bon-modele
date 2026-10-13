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
    action = nil

    booking.with_lock do
      booking.reload

      if booking.paid?
        action = :already_paid
      elsif booking.canceled?
        persist_payment_reference!(booking)
        StripeBookingRefund.refund!(booking)
        action = :refunded_late_payment
      elsif booking.pending_payment?
        mark_paid!(booking)
        action = :confirmed
      end
    end

    deliver_notifications(booking, action)
    booking
  end

  private

  attr_reader :session

  def mark_paid!(booking)
    booking.update!(billing_attributes.merge(status: "paid", paid_at: Time.current))
    booking.payment_transaction.update!(
      status: "paid",
      stripe_payment_intent_id: session.payment_intent,
      tax_amount_cents: tax_amount_cents,
      stripe_payload: session_payload
    )
  end

  def persist_payment_reference!(booking)
    booking.payment_transaction&.update!(
      stripe_payment_intent_id: session.payment_intent,
      tax_amount_cents: tax_amount_cents,
      stripe_payload: session_payload
    )
  end

  def deliver_notifications(booking, action)
    case action
    when :confirmed
      BookingMailer.confirmation(booking).deliver_later
      BookingMailer.admin_notification(booking).deliver_later
    when :refunded_late_payment
      BookingMailer.late_payment_refund(booking).deliver_later
      BookingMailer.admin_late_payment_refund(booking).deliver_later
    end
  end

  def tax_amount_cents
    details = if session.respond_to?(:total_details)
      session.total_details
    elsif session.is_a?(Hash)
      session[:total_details]
    end
    return 0 if details.blank?

    details.respond_to?(:amount_tax) ? details.amount_tax.to_i : details[:amount_tax].to_i
  end

  def session_payload
    session.respond_to?(:to_h) ? session.to_h : {}
  end

  def billing_attributes
    address = customer_address
    return {} if address.blank?

    {
      billing_line1: address_value(address, :line1),
      billing_postal_code: address_value(address, :postal_code),
      billing_city: address_value(address, :city),
      billing_country: address_value(address, :country)
    }.compact_blank
  end

  def customer_address
    customer_details = session_value(:customer_details)
    if customer_details.present?
      billing = customer_details.respond_to?(:address) ? customer_details.address : customer_details[:address]
      return billing if address_value(billing, :country).present?
    end

    session_value(:shipping_details, :address)
  end

  def session_value(*keys)
    keys.reduce(session) do |value, key|
      break if value.blank?

      if value.respond_to?(key)
        value.public_send(key)
      elsif value.is_a?(Hash)
        value[key]
      end
    end
  end

  def address_value(address, key)
    return if address.blank?

    if address.respond_to?(key)
      address.public_send(key)
    elsif address.is_a?(Hash)
      address[key]
    end
  end
end
