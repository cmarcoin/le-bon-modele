module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show destroy sync_stripe release_slot resend_payment_link cancel cancel_and_refund]

    def index
      @bookings = Booking.includes(:pack, :availability_slot, :payment_transaction).latest
      @bookings = @bookings.pending_payment if params[:status] == "pending_payment"
      @pending_payment_count = Booking.pending_payment.count
    end

    def show
    end

    def sync_stripe
      unless @booking.pending_payment?
        redirect_to admin_booking_path(@booking), alert: "Seules les réservations en attente de paiement peuvent être synchronisées."
        return
      end

      outcome = PendingPaymentBookingSync.sync_booking(@booking)

      case outcome
      when :confirmed
        redirect_to admin_booking_path(@booking), notice: "Paiement confirmé — la réservation est maintenant payée."
      when :canceled
        redirect_to admin_booking_path(@booking), notice: "Session Stripe expirée — le créneau a été libéré."
      else
        redirect_to admin_booking_path(@booking), alert: "Aucun changement détecté côté Stripe."
      end
    end

    def release_slot
      unless @booking.pending_payment?
        redirect_to admin_booking_path(@booking), alert: "Seules les réservations en attente de paiement peuvent être libérées."
        return
      end

      result = BookingCancellation.call(@booking, refund: :never, notify: false)
      if result.outcome == :confirmed
        redirect_to admin_booking_path(@booking), notice: "Paiement reçu — la réservation est confirmée."
      else
        redirect_to admin_bookings_path(status: "pending_payment"), notice: "Créneau libéré — la réservation a été annulée."
      end
    end

    def cancel
      if @booking.canceled?
        redirect_to admin_booking_path(@booking), alert: "Cette réservation est déjà annulée."
        return
      end

      result = BookingCancellation.call(@booking, refund: :auto, notify: @booking.paid?)
      redirect_to admin_booking_path(@booking), notice: cancellation_notice(result)
    rescue StripeBookingRefund::Error, Stripe::StripeError => error
      redirect_to admin_booking_path(@booking), alert: "Le remboursement n'a pas pu être effectué : #{error.message}"
    end

    def cancel_and_refund
      unless @booking.paid?
        redirect_to admin_booking_path(@booking), alert: "Seule une réservation payée peut être remboursée."
        return
      end

      result = BookingCancellation.call(@booking, refund: :force, notify: true)
      notice = result.refunded ? "Réservation annulée et paiement remboursé." : "Cette réservation est déjà annulée."
      redirect_to admin_booking_path(@booking), notice: notice
    rescue StripeBookingRefund::Error, Stripe::StripeError => error
      redirect_to admin_booking_path(@booking), alert: "Le remboursement n'a pas pu être effectué : #{error.message}"
    end

    def resend_payment_link
      unless @booking.pending_payment?
        redirect_to admin_booking_path(@booking), alert: "Seules les réservations en attente de paiement peuvent recevoir un lien de paiement."
        return
      end

      BookingMailer.payment_reminder(@booking).deliver_later
      @booking.update!(payment_reminder_sent_at: Time.current)
      redirect_to admin_booking_path(@booking), notice: "Lien de paiement renvoyé à #{@booking.customer_email}."
    end

    def destroy
      if @booking.paid?
        redirect_to admin_booking_path(@booking), alert: "Une réservation payée s'annule depuis sa fiche. Elle n'est pas supprimée."
        return
      end

      if @booking.pending_payment?
        @booking.cancel_reservation!
        redirect_to admin_bookings_path(status: "pending_payment"), notice: "Créneau libéré — la réservation a été annulée."
        return
      end

      Booking.transaction do
        PaymentTransaction.where(booking_id: @booking.id).destroy_all
        @booking.reload.destroy!
      end

      redirect_to admin_bookings_path, notice: "Réservation supprimée."
    end

    private

    def set_booking
      @booking = Booking.includes(:pack, :availability_slot, :payment_transaction, :user).find(params[:id])
    end

    def cancellation_notice(result)
      if result.outcome == :confirmed
        "Paiement reçu — la réservation est confirmée."
      elsif result.refunded
        "Réservation annulée et paiement remboursé."
      elsif result.booking.payment_transaction&.status == "paid"
        "Réservation annulée, sans remboursement."
      else
        "Créneau libéré — la réservation a été annulée."
      end
    end
  end
end
