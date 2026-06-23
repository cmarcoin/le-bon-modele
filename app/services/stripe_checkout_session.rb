class StripeCheckoutSession
  class ConfigurationError < StandardError; end

  def self.create_for(booking, base_url)
    new(booking, base_url).create
  end

  def initialize(booking, base_url)
    @booking = booking
    @base_url = base_url
  end

  def create
    raise ConfigurationError, "STRIPE_SECRET_KEY est manquant." if ENV["STRIPE_SECRET_KEY"].blank?
    raise ConfigurationError, "Le pack n'est pas synchronise avec Stripe. Lancez rails stripe:sync_packs." unless booking.pack.stripe_ready?

    Stripe::Checkout::Session.create(
      mode: "payment",
      locale: "fr",
      customer_email: booking.customer_email,
      customer_creation: "always",
      payment_method_types: [ "card" ],
      billing_address_collection: "required",
      automatic_tax: { enabled: true },
      line_items: [ line_item ],
      client_reference_id: booking.id,
      success_url: "#{base_url}/checkout/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{base_url}/checkout/cancel?booking_id=#{booking.id}",
      metadata: {
        booking_id: booking.id,
        pack_id: booking.pack_id,
        customer_email: booking.customer_email
      }
    )
  end

  private

  attr_reader :booking, :base_url

  def line_item
    {
      quantity: 1,
      price: booking.pack.stripe_price_id
    }
  end
end
