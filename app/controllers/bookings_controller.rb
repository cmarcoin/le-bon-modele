class BookingsController < ApplicationController
  before_action :set_pack

  def new
    @booking = Booking.new(pack: @pack)
    @availability_slots = AvailabilitySlot.available_for(@pack)
  end

  def create
    @availability_slots = AvailabilitySlot.available_for(@pack)
    @booking = Booking.new(booking_params.merge(pack: @pack, amount_cents: @pack.price_cents, currency: @pack.currency))

    Booking.transaction do
      @booking.user = find_or_create_client!
      @booking.save!
      checkout_session = StripeCheckoutSession.create_for(@booking, request.base_url)
      @booking.update!(stripe_checkout_session_id: checkout_session.id)
      PaymentTransaction.create!(
        booking: @booking,
        user: @booking.user,
        pack: @pack,
        status: "pending",
        amount_cents: @booking.amount_cents,
        currency: @booking.currency,
        stripe_checkout_session_id: checkout_session.id,
        stripe_payload: checkout_session.to_h
      )
      redirect_to checkout_session.url, allow_other_host: true
    end
  rescue ActiveRecord::RecordInvalid, StripeCheckoutSession::ConfigurationError => error
    @booking.errors.add(:base, error.message)
    render :new, status: :unprocessable_entity
  rescue Stripe::StripeError => error
    @booking.errors.add(:base, "Le paiement Stripe n'a pas pu etre initialise: #{error.message}")
    render :new, status: :unprocessable_entity
  end

  private

  def set_pack
    @pack = Pack.active.find_by!(slug: params[:pack_slug])
  end

  def booking_params
    params.require(:booking).permit(:availability_slot_id, :customer_name, :customer_email, :customer_phone)
  end

  def find_or_create_client!
    email = booking_params[:customer_email].to_s.strip.downcase
    user = User.find_or_initialize_by(email: email)
    user.name = booking_params[:customer_name] if user.name.blank?
    user.phone = booking_params[:customer_phone] if user.phone.blank?
    user.role = "client" if user.role.blank?
    user.password = Devise.friendly_token.first(32) if user.new_record?
    user.save!
    user
  end
end
