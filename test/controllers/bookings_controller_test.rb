require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  FakeCheckoutSession = Struct.new(:id, :url, keyword_init: true) do
    def to_h
      { id:, url: }
    end
  end

  setup do
    @pack = Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier le modele",
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
  end

  test "shows available exact slots for a pack" do
    get new_pack_booking_path(@pack)

    assert_response :success
    assert_select "h2", "Reservation et paiement"
    assert_select "input[type=radio][value='#{@slot.id}']"
  end

  test "creates client user booking and payment transaction before redirecting to stripe" do
    fake_session = FakeCheckoutSession.new(id: "cs_test_123", url: "https://checkout.stripe.test/session")

    original_create_for = StripeCheckoutSession.method(:create_for)
    StripeCheckoutSession.define_singleton_method(:create_for) { |_booking, _base_url| fake_session }

    begin
      assert_difference -> { User.where(email: "buyer@example.com").count }, 1 do
        assert_difference -> { Booking.count }, 1 do
          assert_difference -> { PaymentTransaction.count }, 1 do
            post pack_bookings_path(@pack), params: {
              booking: {
                availability_slot_id: @slot.id,
                customer_name: "Buyer Test",
                customer_email: "buyer@example.com",
                customer_phone: "0600000000"
              }
            }
          end
        end
      end
    ensure
      StripeCheckoutSession.define_singleton_method(:create_for, original_create_for)
    end

    booking = Booking.last
    assert_redirected_to "https://checkout.stripe.test/session"
    assert_equal "pending_payment", booking.status
    assert_equal "cs_test_123", booking.stripe_checkout_session_id
    assert_equal 5_900, booking.payment_transaction.amount_cents
  end
end
