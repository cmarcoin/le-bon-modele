class BookingCancellationsController < ApplicationController
  before_action :set_booking

  def show
  end

  def create
    if @booking.canceled?
      redirect_to cancel_booking_path(token: params[:token]), alert: "Cette réservation est déjà annulée."
      return
    end

    unless @booking.paid?
      redirect_to cancel_booking_path(token: params[:token]), alert: "Cette réservation ne peut plus être annulée depuis ce lien."
      return
    end

    result = BookingCancellation.call(@booking, refund: :auto, notify: true)
    if result.outcome == :canceled
      notice = if result.refunded
        "Réservation annulée. Le paiement a été remboursé."
      else
        "Réservation annulée. Ce rendez-vous n'est pas remboursé."
      end
      redirect_to cancel_booking_path(token: params[:token]), notice: notice
    else
      redirect_to cancel_booking_path(token: params[:token]), alert: "Cette réservation ne peut pas être annulée."
    end
  rescue StripeBookingRefund::Error, Stripe::StripeError => error
    redirect_to cancel_booking_path(token: params[:token]), alert: "Le remboursement n'a pas pu être effectué : #{error.message}"
  end

  private

  def set_booking
    @booking = Booking.includes(:pack, :availability_slot, :payment_transaction).find_signed!(params[:token], purpose: :booking_cancellation)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "Lien d'annulation invalide ou expiré."
  end
end
