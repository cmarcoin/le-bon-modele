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

    Stripe::Checkout::Session.create(
      mode: "payment",
      customer_email: booking.customer_email,
      client_reference_id: booking.id,
      success_url: "#{base_url}/checkout/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{base_url}/checkout/cancel?booking_id=#{booking.id}",
      automatic_tax: { enabled: true },
      line_items: [ line_item ],
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
      price_data: {
        currency: booking.currency,
        unit_amount: booking.amount_cents,
        tax_behavior: "inclusive",
        product_data: {
          name: booking.pack.name,
          description: booking.pack.objective
        }
      }
    }
  end
end
