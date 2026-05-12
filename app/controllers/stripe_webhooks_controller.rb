class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = stripe_event

    case event.type
    when "checkout.session.completed", "checkout.session.async_payment_succeeded"
      StripeBookingConfirmation.confirm_from_session!(event.data.object)
    when "checkout.session.expired", "checkout.session.async_payment_failed"
      cancel_booking(event.data.object)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def stripe_event
    payload = request.raw_post

    if ENV["STRIPE_WEBHOOK_SECRET"].present?
      Stripe::Webhook.construct_event(payload, request.env["HTTP_STRIPE_SIGNATURE"], ENV.fetch("STRIPE_WEBHOOK_SECRET"))
    elsif !Rails.env.production?
      Stripe::Event.construct_from(JSON.parse(payload))
    else
      raise Stripe::SignatureVerificationError.new("Missing STRIPE_WEBHOOK_SECRET", request.env["HTTP_STRIPE_SIGNATURE"])
    end
  end

  def cancel_booking(session)
    booking = Booking.find_by(stripe_checkout_session_id: session.id)
    return unless booking&.pending_payment?

    booking.update!(status: "canceled")
    booking.payment_transaction&.update!(status: "canceled", stripe_payload: session.to_h)
  end
end
