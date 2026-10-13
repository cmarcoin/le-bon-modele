class Booking < ApplicationRecord
  STATUSES = %w[pending_payment paid canceled].freeze
  MEETING_MODES = %w[visio phone].freeze
  PAYMENT_RESUME_TOKEN_EXPIRY = 7.days
  CHECKOUT_HOLD_DESCRIPTION = "30 minutes"
  REFUND_WINDOW = 48.hours
  REFUND_WINDOW_DESCRIPTION = "48 heures"

  belongs_to :user
  belongs_to :pack
  belongs_to :availability_slot
  has_one :payment_transaction, dependent: :restrict_with_exception

  normalizes :customer_email, with: ->(email) { email.to_s.strip.downcase }

  validates :status, inclusion: { in: STATUSES }
  validates :customer_name, :customer_email, :amount_cents, :currency, presence: true
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :amount_cents, numericality: { greater_than: 0, only_integer: true }
  validates :meeting_mode, inclusion: { in: MEETING_MODES }, allow_blank: true
  validate :slot_matches_pack
  validate :availability_slot_available

  scope :latest, -> { order(created_at: :desc) }
  scope :occupying_slot, -> { where(status: %w[pending_payment paid]) }
  scope :pending_payment, -> { where(status: "pending_payment") }
  scope :paid, -> { where(status: "paid") }
  scope :due_for_appointment_reminder, -> {
    paid
      .where(appointment_reminder_sent_at: nil)
      .where("bookings.paid_at IS NULL OR bookings.paid_at <= ?", 2.hours.ago)
      .joins(:availability_slot)
      .where(availability_slots: { starts_at: Time.current..24.hours.from_now })
  }

  def paid?
    status == "paid"
  end

  def pending_payment?
    status == "pending_payment"
  end

  def canceled?
    status == "canceled"
  end

  def refundable?
    paid? && !payment_transaction&.refunded? && availability_slot.starts_at > REFUND_WINDOW.from_now
  end

  def payment_resume_token
    signed_id(purpose: :payment_resume, expires_in: PAYMENT_RESUME_TOKEN_EXPIRY)
  end

  def cancellation_token
    remaining = availability_slot.starts_at - Time.current + 2.days
    signed_id(purpose: :booking_cancellation, expires_in: [ remaining, 2.days ].max)
  end

  def self.release_pending_for_retry!(slot_id:, customer_email:)
    booking = occupying_slot.find_by(
      availability_slot_id: slot_id,
      customer_email: customer_email.to_s.strip.downcase,
      status: "pending_payment"
    )
    booking&.cancel_reservation!
  end

  def cancel_reservation!(expire_session: true)
    if expire_session && stripe_checkout_session_id.present?
      session_state = StripeCheckoutSession.expire_open_session!(self)
      if session_state == :complete
        session = Stripe::Checkout::Session.retrieve(stripe_checkout_session_id)
        return StripeBookingConfirmation.confirm_from_session!(session)
      end
    end

    with_lock do
      reload
      return self unless pending_payment?

      update!(status: "canceled", canceled_at: Time.current)
      payment_transaction.update!(status: "canceled") if payment_transaction&.status == "pending"
    end

    self
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
