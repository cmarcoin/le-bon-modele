class BookingMailer < ApplicationMailer
  helper ApplicationHelper

  ADMIN_RECIPIENTS = User::ADMIN_EMAILS

  def confirmation(booking)
    @booking = booking
    @cancel_url = cancel_booking_url(token: booking.cancellation_token)
    mail(to: booking.customer_email, subject: "Votre rendez-vous Le Bon Modèle est confirmé")
  end

  def admin_notification(booking)
    @booking = booking
    mail(to: ADMIN_RECIPIENTS, subject: "Nouvelle réservation payée - #{booking.pack.name}")
  end

  def cancellation(booking)
    @booking = booking
    @refunded = booking.payment_transaction&.refunded?
    mail(to: booking.customer_email, subject: "Votre réservation Le Bon Modèle est annulée")
  end

  def admin_cancellation(booking)
    @booking = booking
    @refunded = booking.payment_transaction&.refunded?
    mail(to: ADMIN_RECIPIENTS, subject: "Réservation annulée - #{booking.pack.name}")
  end

  def appointment_reminder(booking)
    @booking = booking
    @cancel_url = cancel_booking_url(token: booking.cancellation_token)
    mail(to: booking.customer_email, subject: "Rappel de votre rendez-vous Le Bon Modèle")
  end

  def late_payment_refund(booking)
    @booking = booking
    mail(to: booking.customer_email, subject: "Votre paiement a été remboursé")
  end

  def admin_late_payment_refund(booking)
    @booking = booking
    mail(to: ADMIN_RECIPIENTS, subject: "Paiement remboursé après annulation - #{booking.pack.name}")
  end

  def payment_reminder(booking)
    @booking = booking
    @resume_url = resume_payment_url(token: booking.payment_resume_token)
    mail(to: booking.customer_email, subject: "Finalisez votre réservation Le Bon Modèle")
  end

  def admin_pending_payment_cleanup(canceled_count:, confirmed_count:)
    @canceled_count = canceled_count
    @confirmed_count = confirmed_count
    mail(to: ADMIN_RECIPIENTS, subject: "Créneaux libérés — paiements en attente expirés")
  end
end
