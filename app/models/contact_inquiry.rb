class ContactInquiry
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :first_name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :company, :string

  validates :first_name, :email, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :company_must_be_blank

  private

  def company_must_be_blank
    errors.add(:base, "Impossible d'envoyer le message.") if company.present?
  end
end
