class PaymentResumesController < ApplicationController
  def show
    @booking = Booking.find_signed!(params[:token], purpose: :payment_resume)

    if @booking.paid?
      redirect_to checkout_success_path(session_id: @booking.stripe_checkout_session_id)
      return
    end

    unless @booking.pending_payment?
      redirect_to root_path, alert: "Cette réservation n'est plus en attente de paiement."
      return
    end

    checkout_url = StripeCheckoutSession.checkout_url_for(@booking, request.base_url)
    unless StripeCheckoutSession.trusted_checkout_url?(checkout_url)
      redirect_to root_path, alert: "Le lien de paiement reçu n'est pas valide."
      return
    end

    redirect_to checkout_url, allow_other_host: true
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "Lien de paiement invalide ou expiré."
  rescue StripeCheckoutSession::ConfigurationError => error
    redirect_to root_path, alert: error.message
  rescue Stripe::StripeError => error
    redirect_to root_path, alert: "Le paiement n'a pas pu être relancé : #{error.message}"
  end
end
