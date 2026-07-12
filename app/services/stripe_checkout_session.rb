class StripeCheckoutSession
  class ConfigurationError < StandardError; end

  SESSION_EXPIRY = 60.minutes
  TRUSTED_CHECKOUT_HOST = "checkout.stripe.com"

  def self.create_for(booking, base_url)
    new(booking, base_url).create
  end

  def self.checkout_url_for(booking, base_url)
    new(booking, base_url).checkout_url
  end

  def self.trusted_checkout_url?(url)
    uri = URI.parse(url.to_s)
    uri.scheme == "https" && uri.host == TRUSTED_CHECKOUT_HOST
  rescue URI::InvalidURIError
    false
  end

  def initialize(booking, base_url)
    @booking = booking
    @base_url = base_url
  end

  def create
    raise ConfigurationError, "STRIPE_SECRET_KEY est manquant." if ENV["STRIPE_SECRET_KEY"].blank?
    raise ConfigurationError, "Le pack n'est pas synchronisé avec Stripe. Lancez rails stripe:sync_packs." unless booking.pack.stripe_ready?

    Stripe::Checkout::Session.create(session_params)
  end

  def checkout_url
    if booking.stripe_checkout_session_id.present?
      existing = retrieve_session(booking.stripe_checkout_session_id)
      return existing.url if session_open?(existing)
    end

    replace_session!
  end

  private

  attr_reader :booking, :base_url

  def session_params
    {
      mode: "payment",
      locale: "fr",
      customer_email: booking.customer_email,
      customer_creation: "always",
      payment_method_types: [ "card" ],
      billing_address_collection: "required",
      automatic_tax: { enabled: true },
      line_items: [ line_item ],
      client_reference_id: booking.id,
      expires_at: SESSION_EXPIRY.from_now.to_i,
      success_url: "#{base_url}/checkout/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{base_url}/checkout/cancel?booking_id=#{booking.id}",
      metadata: {
        booking_id: booking.id,
        pack_id: booking.pack_id,
        customer_email: booking.customer_email
      }
    }
  end

  def line_item
    {
      quantity: 1,
      price: booking.pack.stripe_price_id
    }
  end

  def retrieve_session(session_id)
    Stripe::Checkout::Session.retrieve(session_id)
  end

  def session_open?(session)
    session.status == "open" && !session_expired?(session)
  end

  def session_expired?(session)
    expires_at = session.respond_to?(:expires_at) ? session.expires_at : session[:expires_at]
    expires_at.present? && Time.zone.at(expires_at) <= Time.current
  end

  def replace_session!
    session = create

    Booking.transaction do
      booking.update!(stripe_checkout_session_id: session.id)
      booking.payment_transaction&.update!(
        stripe_checkout_session_id: session.id,
        stripe_payload: session.to_h
      )
    end

    session.url
  end
end
