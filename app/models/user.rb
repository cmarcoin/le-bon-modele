class User < ApplicationRecord
  ADMIN_EMAILS = %w[
    charles.marcoin@gmail.com
    delmas.jules@gmail.com
  ].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :restrict_with_exception
  has_many :payment_transactions, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :role, inclusion: { in: %w[admin client] }

  def admin?
    role == "admin"
  end
end
