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
end
