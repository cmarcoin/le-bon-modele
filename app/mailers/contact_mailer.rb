class ContactMailer < ApplicationMailer
  RECIPIENT = ENV.fetch("CONTACT_RECIPIENT", "contact@lebonmodele.fr")

  def inquiry(first_name:, email:, message:)
    @contact_inquiry = ContactInquiry.new(first_name:, email:, message:)

    mail(
      to: RECIPIENT,
      reply_to: email,
      subject: "Contact Le Bon Modèle — #{first_name}"
    )
  end
end
