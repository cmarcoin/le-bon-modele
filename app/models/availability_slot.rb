class AvailabilitySlot < ApplicationRecord
  DEFAULT_TIMEZONE = "Europe/Paris"

  belongs_to :pack, optional: true
  has_many :bookings, dependent: :restrict_with_exception
  has_one :active_booking, -> { occupying_slot }, class_name: "Booking", inverse_of: :availability_slot

  normalizes :colleague_email, with: ->(email) { email.to_s.strip.downcase }

  validates :starts_at, :ends_at, :timezone, :colleague_name, :colleague_email, presence: true
  validates :colleague_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :ends_after_start

  scope :active, -> { where(active: true) }
  scope :upcoming, -> { where(starts_at: Time.current..) }
  scope :available_for, ->(pack) {
    active
      .upcoming
      .where(pack_id: [ nil, pack.id ])
      .where.not(id: Booking.occupying_slot.select(:availability_slot_id))
      .order(:starts_at)
  }

  def title
    "#{starts_at.in_time_zone(timezone).strftime("%d/%m/%Y %H:%M")} avec #{colleague_name}"
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "doit etre apres le debut") if ends_at <= starts_at
  end
end
