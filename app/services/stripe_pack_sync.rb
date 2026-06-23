class StripePackSync
  class Error < StandardError; end
  class ConfigurationError < Error; end

  CONSULTING_TAX_CODE = "txcd_20060048"

  def self.sync!(pack)
    new(pack).sync!
  end

  def initialize(pack)
    @pack = pack
  end

  def sync!
    raise ConfigurationError, "STRIPE_SECRET_KEY est manquant." unless stripe_configured?

    product = ensure_product!
    price = ensure_price!(product)
    pack.update!(stripe_product_id: product.id, stripe_price_id: price.id)
    pack
  end

  private

  attr_reader :pack

  def stripe_configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def ensure_product!
    product = pack.stripe_product_id.present? ? retrieve_product : nil
    product ||= Stripe::Product.create(product_attributes)
    Stripe::Product.update(product.id, product_attributes)
    product
  rescue Stripe::InvalidRequestError => error
    raise Error, "Impossible de synchroniser le produit Stripe: #{error.message}"
  end

  def retrieve_product
    Stripe::Product.retrieve(pack.stripe_product_id)
  rescue Stripe::InvalidRequestError
    nil
  end

  def product_attributes
    {
      name: pack.name,
      description: pack.objective,
      tax_code: CONSULTING_TAX_CODE,
      active: pack.active?,
      metadata: {
        pack_id: pack.id,
        pack_slug: pack.slug
      }
    }
  end

  def ensure_price!(product)
    if current_price_matches?
      return Stripe::Price.retrieve(pack.stripe_price_id)
    end

    deactivate_current_price!
    Stripe::Price.create(price_attributes(product.id))
  rescue Stripe::InvalidRequestError => error
    raise Error, "Impossible de synchroniser le prix Stripe: #{error.message}"
  end

  def current_price_matches?
    return false if pack.stripe_price_id.blank?

    price = Stripe::Price.retrieve(pack.stripe_price_id)
    price.active &&
      price.unit_amount == pack.price_cents &&
      price.currency == pack.currency
  rescue Stripe::InvalidRequestError
    false
  end

  def deactivate_current_price!
    return if pack.stripe_price_id.blank?

    Stripe::Price.update(pack.stripe_price_id, active: false)
  rescue Stripe::InvalidRequestError
    nil
  end

  def price_attributes(product_id)
    {
      product: product_id,
      unit_amount: pack.price_cents,
      currency: pack.currency,
      tax_behavior: "inclusive",
      metadata: {
        pack_id: pack.id,
        pack_slug: pack.slug
      }
    }
  end
end
