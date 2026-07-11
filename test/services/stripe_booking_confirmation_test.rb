require "test_helper"
require "ostruct"

class StripeBookingConfirmationTest < ActiveSupport::TestCase
  setup do
    @pack = Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier",
      description: "Description",
      price_cents: 5_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/starter-pack.svg",
      accent_class: "text-brand-accent"
    )
    @slot = AvailabilitySlot.create!(
      starts_at: 2.days.from_now.change(hour: 10),
      ends_at: 2.days.from_now.change(hour: 10, min: 45),
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "contact@lebonmodele.fr"
    )
    @booking = Booking.create!(
      user: users(:client),
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Client Test",
      customer_email: "client@example.com",
      amount_cents: 5_900,
      currency: "eur",
      stripe_checkout_session_id: "cs_test_confirm"
    )
    PaymentTransaction.create!(
      booking: @booking,
      user: users(:client),
      pack: @pack,
      amount_cents: 5_900,
      currency: "eur",
      stripe_checkout_session_id: "cs_test_confirm"
    )
  end

  test "stores stripe tax amount from checkout session" do
    session = OpenStruct.new(
      id: "cs_test_confirm",
      payment_status: "paid",
      payment_intent: "pi_test_123",
      amount_total: 5_900,
      total_details: OpenStruct.new(amount_tax: 983)
    )

    StripeBookingConfirmation.confirm_from_session!(session)

    assert_equal 983, @booking.payment_transaction.reload.tax_amount_cents
  end

  test "stores billing address collected by stripe checkout" do
    session = OpenStruct.new(
      id: "cs_test_confirm",
      payment_status: "paid",
      payment_intent: "pi_test_123",
      amount_total: 5_900,
      total_details: OpenStruct.new(amount_tax: 983),
      customer_details: OpenStruct.new(
        address: OpenStruct.new(
          line1: "119 boulevard Saint-Michel",
          postal_code: "75005",
          city: "Paris",
          country: "FR"
        )
      )
    )

    StripeBookingConfirmation.confirm_from_session!(session)

    @booking.reload
    assert_equal "119 boulevard Saint-Michel", @booking.billing_line1
    assert_equal "75005", @booking.billing_postal_code
    assert_equal "Paris", @booking.billing_city
    assert_equal "FR", @booking.billing_country
  end
end
