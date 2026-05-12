require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

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
      colleague_email: "charles.marcoin@gmail.com"
    )
    @booking = Booking.create!(
      user: users(:client),
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Client Test",
      customer_email: "client@example.com",
      amount_cents: 5_900,
      currency: "eur",
      stripe_checkout_session_id: "cs_test_webhook"
    )
    @transaction = PaymentTransaction.create!(
      booking: @booking,
      user: users(:client),
      pack: @pack,
      amount_cents: 5_900,
      currency: "eur",
      stripe_checkout_session_id: "cs_test_webhook"
    )
  end

  test "completed checkout webhook confirms booking and logs transaction details" do
    payload = {
      id: "evt_test",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_webhook",
          object: "checkout.session",
          payment_status: "paid",
          payment_intent: "pi_test_123",
          total_details: { amount_tax: 983 }
        }
      }
    }.to_json

    assert_enqueued_emails 2 do
      post stripe_webhooks_path, params: payload, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :success
    assert_equal "paid", @booking.reload.status
    assert_not_nil @booking.paid_at
    assert_equal "paid", @transaction.reload.status
    assert_equal "pi_test_123", @transaction.stripe_payment_intent_id
    assert_equal 983, @transaction.tax_amount_cents
  end
end
