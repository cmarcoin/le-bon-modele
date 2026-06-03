require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @client = users(:client)
    @pack = Pack.create!(
      slug: "pack-premium",
      name: "Pack Premium",
      objective: "Accompagnement",
      description: "Description",
      price_cents: 29_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/pack-premium.svg",
      accent_class: "text-brand-coral"
    )
  end

  test "admin can update pack price" do
    sign_in @admin

    patch admin_pack_path(@pack), params: {
      pack: {
        name: @pack.name,
        objective: @pack.objective,
        description: @pack.description,
        price_cents: 39_900,
        duration_minutes: 45,
        active: true
      }
    }

    assert_redirected_to admin_packs_path
    assert_equal 39_900, @pack.reload.price_cents
  end

  test "client cannot access admin" do
    sign_in @client

    get admin_root_path

    assert_redirected_to root_path
  end

  test "admin can create exact availability slot" do
    sign_in @admin

    assert_difference -> { AvailabilitySlot.count }, 1 do
      post admin_availability_slots_path, params: {
        availability_slot: {
          starts_at: 3.days.from_now.change(hour: 14),
          ends_at: 3.days.from_now.change(hour: 14, min: 45),
          timezone: "Europe/Paris",
          colleague_name: "Jules Delmas",
          colleague_email: "delmas.jules@gmail.com",
          pack_id: @pack.id,
          active: true
        }
      }
    end

    assert_redirected_to admin_availability_slots_path
    assert_equal "Jules Delmas", AvailabilitySlot.last.colleague_name
  end

  test "admin can delete availability slot without booking" do
    sign_in @admin
    slot = AvailabilitySlot.create!(
      starts_at: 2.days.from_now.change(hour: 10),
      ends_at: 2.days.from_now.change(hour: 10, min: 45),
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "charles.marcoin@gmail.com",
      pack: @pack,
      active: true
    )

    assert_difference -> { AvailabilitySlot.count }, -1 do
      delete admin_availability_slot_path(slot)
    end

    assert_redirected_to admin_availability_slots_path
    assert_equal "Creneau supprime.", flash[:notice]
  end

  test "admin cannot delete availability slot with booking" do
    sign_in @admin
    slot = AvailabilitySlot.create!(
      starts_at: 2.days.from_now.change(hour: 11),
      ends_at: 2.days.from_now.change(hour: 11, min: 45),
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "charles.marcoin@gmail.com",
      pack: @pack,
      active: true
    )
    Booking.create!(
      user: @client,
      pack: @pack,
      availability_slot: slot,
      customer_name: "Client Test",
      customer_email: @client.email,
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "pending_payment"
    )

    assert_no_difference -> { AvailabilitySlot.count } do
      delete admin_availability_slot_path(slot)
    end

    assert_redirected_to admin_availability_slots_path
    assert_match(/reserve/, flash[:alert])
  end

  test "admin can delete booking and payment transaction" do
    sign_in @admin
    slot = AvailabilitySlot.create!(
      starts_at: 2.days.from_now.change(hour: 12),
      ends_at: 2.days.from_now.change(hour: 12, min: 45),
      timezone: "Europe/Paris",
      colleague_name: "Charles Marcoin",
      colleague_email: "charles.marcoin@gmail.com",
      pack: @pack,
      active: true
    )
    booking = Booking.create!(
      user: @client,
      pack: @pack,
      availability_slot: slot,
      customer_name: "Client Test",
      customer_email: @client.email,
      amount_cents: @pack.price_cents,
      currency: "eur",
      status: "paid"
    )
    PaymentTransaction.create!(
      booking: booking,
      user: @client,
      pack: @pack,
      amount_cents: booking.amount_cents,
      currency: "eur",
      status: "paid",
      stripe_checkout_session_id: "cs_test_#{booking.id}",
      tax_amount_cents: 0
    )

    assert_difference -> { Booking.count }, -1 do
      assert_difference -> { PaymentTransaction.count }, -1 do
        delete admin_booking_path(booking)
      end
    end

    assert_redirected_to admin_bookings_path
    assert_equal "Reservation supprimee.", flash[:notice]
    assert slot.reload
  end
end
