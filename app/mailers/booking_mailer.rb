class BookingMailer < ApplicationMailer
  helper ApplicationHelper

  ADMIN_RECIPIENTS = User::ADMIN_EMAILS

  def confirmation(booking)
    @booking = booking
    mail(to: booking.customer_email, subject: "Votre rendez-vous Le Bon Modele est confirme")
  end

  def admin_notification(booking)
    @booking = booking
    mail(to: ADMIN_RECIPIENTS, subject: "Nouvelle reservation payee - #{booking.pack.name}")
  end
end
