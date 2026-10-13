class BookingCancellation
  Result = Struct.new(:booking, :refunded, :outcome, keyword_init: true)

  def self.call(booking, refund: :auto, notify: true)
    new(booking, refund:, notify:).call
  end

  def initialize(booking, refund:, notify:)
    @booking = booking
    @refund = refund
    @notify = notify
  end

  def call
    if booking.pending_payment?
      booking.cancel_reservation!
      booking.reload
      outcome = booking.paid? ? :confirmed : :canceled
      return Result.new(booking:, refunded: false, outcome:)
    end

    refunded = false
    outcome = :not_cancelable

    booking.with_lock do
      booking.reload

      if booking.canceled?
        outcome = :already_canceled
      elsif booking.paid?
        if refund_requested?
          StripeBookingRefund.refund!(booking)
          refunded = true
        end

        booking.update!(status: "canceled", canceled_at: Time.current)
        outcome = :canceled
      end
    end

    if notify && outcome == :canceled
      BookingMailer.cancellation(booking).deliver_later
      BookingMailer.admin_cancellation(booking).deliver_later
    end

    Result.new(booking: booking.reload, refunded:, outcome:)
  end

  private

  attr_reader :booking, :refund, :notify

  def refund_requested?
    return true if refund == :force

    refund == :auto && booking.refundable?
  end
end
