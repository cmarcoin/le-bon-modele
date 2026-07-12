require "test_helper"

class PendingPaymentBookingSyncTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @pack = create_pack_with_stripe
    @slot = create_slot(@pack)
    @booking = create_pending_booking(@pack, @slot, session_id: "cs_sync_pending")
    @transaction = create_payment_transaction(@booking, session_id: "cs_sync_pending")
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"
  end

  teardown do
    ENV.delete("STRIPE_SECRET_KEY")
  end

  test "confirms booking when stripe session is paid" do
    stub_stripe_retrieve(payment_status: "paid", status: "complete", payment_intent: "pi_paid")

    assert_enqueued_emails 2 do
      result = PendingPaymentBookingSync.call
      assert_equal 1, result.confirmed_count
      assert_equal 0, result.canceled_count
    end

    assert_equal "paid", @booking.reload.status
    assert_equal "paid", @transaction.reload.status
  end

  test "cancels booking when stripe session is expired" do
    stub_stripe_retrieve(payment_status: "unpaid", status: "expired", expires_at: 2.hours.ago.to_i)

    result = PendingPaymentBookingSync.call
    assert_equal 0, result.confirmed_count
    assert_equal 1, result.canceled_count

    assert_equal "canceled", @booking.reload.status
    assert_equal "canceled", @transaction.reload.status
  end

  test "leaves open unpaid sessions unchanged" do
    stub_stripe_retrieve(payment_status: "unpaid", status: "open", expires_at: 30.minutes.from_now.to_i)

    result = PendingPaymentBookingSync.call
    assert_equal 0, result.confirmed_count
    assert_equal 0, result.canceled_count
    assert_equal 1, result.unchanged_count
    assert_equal "pending_payment", @booking.reload.status
  end

  private

  def create_pack_with_stripe
    Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier",
      description: "Description",
      price_cents: 5_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/starter-pack.svg",
      accent_class: "text-brand-accent",
      stripe_product_id: "prod_test",
      stripe_price_id: "price_test"
    )
  end

  def create_slot(pack)
    AvailabilitySlot.create!(
      pack: pack,
      starts_at: 2.days.from_now.change(hour: 10),
      ends_at: 2.days.from_now.change(hour: 10, min: 45),
      timezone: "Europe/Paris"
    )
  end

  def create_pending_booking(pack, slot, session_id:)
    Booking.create!(
      user: users(:client),
      pack: pack,
      availability_slot: slot,
      customer_name: "Client Test",
      customer_email: "client@example.com",
      amount_cents: pack.price_cents,
      currency: "eur",
      status: "pending_payment",
      stripe_checkout_session_id: session_id
    )
  end

  def create_payment_transaction(booking, session_id:)
    PaymentTransaction.create!(
      booking: booking,
      user: booking.user,
      pack: booking.pack,
      amount_cents: booking.amount_cents,
      currency: booking.currency,
      stripe_checkout_session_id: session_id
    )
  end

  def stub_stripe_retrieve(payment_status:, status:, payment_intent: nil, expires_at: nil)
    session = Struct.new(:id, :payment_status, :status, :payment_intent, :expires_at, :customer_details, :to_h, keyword_init: true).new(
      id: "cs_sync_pending",
      payment_status: payment_status,
      status: status,
      payment_intent: payment_intent,
      expires_at: expires_at,
      customer_details: nil,
      to_h: { id: "cs_sync_pending", payment_status: payment_status, status: status }
    )

    Stripe::Checkout::Session.define_singleton_method(:retrieve) { |_id| session }
  end
end
