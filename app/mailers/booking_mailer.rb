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
end
