class Pack < ApplicationRecord
  has_many :availability_slots, dependent: :nullify
  has_many :bookings, dependent: :restrict_with_exception
  has_many :payment_transactions, dependent: :restrict_with_exception

  normalizes :slug, with: ->(slug) { slug.to_s.parameterize }
  normalizes :currency, with: ->(currency) { currency.to_s.downcase }

  validates :slug, :name, :objective, :description, :price_cents, :currency, :duration_minutes, :icon_path, :accent_class, presence: true
  validates :slug, uniqueness: true
  validates :price_cents, numericality: { greater_than: 0, only_integer: true }
  validates :duration_minutes, numericality: { greater_than: 0, only_integer: true }

  scope :active, -> { where(active: true) }

  def to_param
    slug
  end

  def price_euros
    price_cents / 100
  end
end
