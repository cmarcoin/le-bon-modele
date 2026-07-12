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
      timezone: "Europe/Paris"
    )
  end

  test "shows calendly style month calendar for available slots" do
    get new_pack_booking_path(@pack)

    assert_response :success
    assert_select "h2", "Réservation et paiement"
    assert_select "[data-controller='booking-scheduler']"
    assert_select "[data-booking-scheduler-target='calendar']"
    assert_select "[data-booking-scheduler-target='monthLabel']"
    assert_select "input[type=radio][value='#{@slot.id}']"
  end

  test "supports month and date query params like calendly" do
    slot_date = @slot.starts_at.in_time_zone("Europe/Paris").to_date

    get new_pack_booking_path(@pack, month: slot_date.strftime("%Y-%m"), date: slot_date.iso8601)

    assert_response :success
    assert_select "[data-booking-scheduler-initial-month-value='#{slot_date.strftime("%Y-%m")}']"
    assert_select "[data-booking-scheduler-initial-date-value='#{slot_date.iso8601}']"
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

  test "allows retrying checkout after a failed stripe initialization" do
    Booking.create!(
      user: User.create!(email: "buyer@example.com", name: "Buyer Test", password: "password123456", role: "client"),
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Buyer Test",
      customer_email: "buyer@example.com",
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "pending_payment"
    )

    fake_session = FakeCheckoutSession.new(id: "cs_test_456", url: "https://checkout.stripe.test/retry")
    original_create_for = StripeCheckoutSession.method(:create_for)
    StripeCheckoutSession.define_singleton_method(:create_for) { |_booking, _base_url| fake_session }

    begin
      assert_difference -> { Booking.occupying_slot.count }, 0 do
        post pack_bookings_path(@pack), params: {
          booking: {
            availability_slot_id: @slot.id,
            customer_name: "Buyer Test",
            customer_email: "buyer@example.com",
            customer_phone: "0600000000"
          }
        }
      end
    ensure
      StripeCheckoutSession.define_singleton_method(:create_for, original_create_for)
    end

    booking = Booking.occupying_slot.last
    assert_redirected_to "https://checkout.stripe.test/retry"
    assert_equal "cs_test_456", booking.stripe_checkout_session_id
    assert_equal 1, Booking.where(availability_slot_id: @slot.id, status: "canceled").count
  end

  test "canceled bookings free the slot for a new reservation" do
    user = User.create!(email: "buyer@example.com", name: "Buyer Test", password: "password123456", role: "client")
    Booking.create!(
      user: user,
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Buyer Test",
      customer_email: "buyer@example.com",
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "canceled"
    )

    assert_includes AvailabilitySlot.available_for(@pack), @slot
  end
end
