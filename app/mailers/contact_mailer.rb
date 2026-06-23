class ContactMailer < ApplicationMailer
  RECIPIENT = ENV.fetch("CONTACT_RECIPIENT", "charles.marcoin@gmail.com")

  def inquiry(contact_inquiry)
    @contact_inquiry = contact_inquiry

    mail(
      to: RECIPIENT,
      reply_to: contact_inquiry.email,
      subject: "Contact Le Bon Modèle — #{contact_inquiry.first_name}"
    )
  end
end
