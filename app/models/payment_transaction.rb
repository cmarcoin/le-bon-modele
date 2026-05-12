class PaymentTransaction < ApplicationRecord
  STATUSES = %w[pending paid failed canceled].freeze

  belongs_to :booking
  belongs_to :user
  belongs_to :pack

  validates :status, inclusion: { in: STATUSES }
  validates :amount_cents, :currency, :stripe_checkout_session_id, presence: true
  validates :amount_cents, :tax_amount_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :stripe_checkout_session_id, uniqueness: true
end
