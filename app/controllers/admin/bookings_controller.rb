module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show destroy sync_stripe release_slot resend_payment_link]

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

      @booking.cancel_reservation!
      redirect_to admin_bookings_path(status: "pending_payment"), notice: "Créneau libéré — la réservation a été annulée."
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
  end
end
