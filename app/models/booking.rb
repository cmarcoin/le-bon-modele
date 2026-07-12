class Booking < ApplicationRecord
  STATUSES = %w[pending_payment paid canceled].freeze
  PAYMENT_REMINDER_DELAY = 1.hour
  PAYMENT_RESUME_TOKEN_EXPIRY = 7.days

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
  validate :availability_slot_available

  scope :latest, -> { order(created_at: :desc) }
  scope :occupying_slot, -> { where(status: %w[pending_payment paid]) }
  scope :pending_payment, -> { where(status: "pending_payment") }
  scope :due_for_payment_reminder, -> {
    pending_payment
      .where(payment_reminder_sent_at: nil)
      .where(created_at: ..PAYMENT_REMINDER_DELAY.ago)
  }

  def paid?
    status == "paid"
  end

  def pending_payment?
    status == "pending_payment"
  end

  def payment_resume_token
    signed_id(purpose: :payment_resume, expires_in: PAYMENT_RESUME_TOKEN_EXPIRY)
  end

  def self.release_pending_for_retry!(slot_id:, customer_email:)
    booking = occupying_slot.find_by(
      availability_slot_id: slot_id,
      customer_email: customer_email.to_s.strip.downcase,
      status: "pending_payment"
    )
    booking&.cancel_reservation!
  end

  def cancel_reservation!
    transaction do
      update!(status: "canceled")
      payment_transaction&.update!(status: "canceled")
    end
  end

  private

  def availability_slot_available
    return if availability_slot_id.blank?

    existing = self.class.occupying_slot.where(availability_slot_id: availability_slot_id)
    existing = existing.where.not(id: id) if persisted?

    errors.add(:availability_slot, "n'est plus disponible") if existing.exists?
  end

  def slot_matches_pack
    return if availability_slot.blank? || pack.blank?
    return if availability_slot.pack_id.blank? || availability_slot.pack_id == pack_id

    errors.add(:availability_slot, "n'est pas disponible pour ce pack")
  end
end
