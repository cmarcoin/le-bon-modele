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

  def stripe_ready?
    stripe_product_id.present? && stripe_price_id.present?
  end

  DEFAULT_INCLUDES = {
    "starter-pack" => [
      "Un questionnaire préparatoire,",
      "Un premier entretien de 60 minutes avec Charles et Jules,",
      "Un document de synthèse et une pré-sélection de modèles,",
      "Un entretien de suivi de 30 minutes."
    ],
    "pack-premium" => [
      "Un questionnaire préparatoire,",
      "Trois entretiens de 60 minutes chacun avec Charles et Jules,",
      "Un document de synthèse avec une présélection de 2 à 3 modèles,",
      "Une sélection de 4 à 5 annonces avec un comparatif détaillé,",
      "Un accompagnement pour répondre à vos questions entre les rendez-vous."
    ]
  }.freeze

  def includes_items
    items = includes_text.to_s.split(/\r?\n/).map(&:strip).compact_blank
    items.presence || DEFAULT_INCLUDES.fetch(slug, [])
  end

  def stripe_description
    case slug
    when "starter-pack"
      "Identifier le modèle de voiture qu’il vous faut"
    else
      objective
    end
  end
end
