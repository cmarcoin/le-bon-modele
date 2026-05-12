class CheckoutController < ApplicationController
  def success
    @booking = Booking.find_by(stripe_checkout_session_id: params[:session_id])
    confirm_from_stripe if @booking&.pending_payment? && ENV["STRIPE_SECRET_KEY"].present?
  end

  def cancel
    @booking = Booking.find_by(id: params[:booking_id])
    @booking&.update!(status: "canceled") if @booking&.pending_payment?
  end

  private

  def confirm_from_stripe
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    StripeBookingConfirmation.confirm_from_session!(session)
    @booking.reload
  rescue Stripe::StripeError, ActiveRecord::RecordNotFound
    Rails.logger.warn("Stripe success confirmation deferred for session #{params[:session_id]}")
  end
end
