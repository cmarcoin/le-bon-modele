class Booking < ApplicationRecord
  STATUSES = %w[pending_payment paid canceled].freeze

  belongs_to :user
  belongs_to :pack
  belongs_to :availability_slot
  has_one :payment_transaction, dependent: :restrict_with_exception

  normalizes :customer_email, with: ->(email) { email.to_s.strip.downcase }

  validates :status, inclusion: { in: STATUSES }
  validates :customer_name, :customer_email, :amount_cents, :currency, presence: true
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :amount_cents, numericality: { greater_than: 0, only_integer: true }
  validate :slot_matches_pack

  scope :latest, -> { order(created_at: :desc) }

  def paid?
    status == "paid"
  end

  def pending_payment?
    status == "pending_payment"
  end

  private

  def slot_matches_pack
    return if availability_slot.blank? || pack.blank?
    return if availability_slot.pack_id.blank? || availability_slot.pack_id == pack_id

    errors.add(:availability_slot, "n'est pas disponible pour ce pack")
  end
end
