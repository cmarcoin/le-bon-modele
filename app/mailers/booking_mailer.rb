class BookingMailer < ApplicationMailer
  helper ApplicationHelper

  ADMIN_RECIPIENTS = User::ADMIN_EMAILS

  def confirmation(booking)
    @booking = booking
    mail(to: booking.customer_email, subject: "Votre rendez-vous Le Bon Modèle est confirmé")
  end

  def admin_notification(booking)
    @booking = booking
    mail(to: ADMIN_RECIPIENTS, subject: "Nouvelle réservation payée - #{booking.pack.name}")
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
