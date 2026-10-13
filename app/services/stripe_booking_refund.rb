class StripeBookingRefund
  class Error < StandardError; end

  def self.refund!(booking)
    new(booking).refund!
  end

  def initialize(booking)
    @booking = booking
  end

  def refund!
    transaction = booking.payment_transaction
    raise Error, "Aucun paiement Stripe à rembourser." if transaction&.stripe_payment_intent_id.blank?
    return transaction if transaction.refunded?

    refund = Stripe::Refund.create(
      { payment_intent: transaction.stripe_payment_intent_id },
      { idempotency_key: "booking-#{booking.id}-refund" }
    )

    transaction.update!(
      status: "refunded",
      stripe_refund_id: refund.id,
      refunded_at: Time.current
    )
    transaction
  end

  private

  attr_reader :booking
end
