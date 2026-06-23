require "test_helper"

class AvailabilitySlotBulkCreatorTest < ActiveSupport::TestCase
  setup do
    @start_date = Date.new(2026, 6, 10)
    @end_date = Date.new(2026, 6, 11)
  end

  test "creates hourly 45 minute slots for each day in range" do
    result = AvailabilitySlotBulkCreator.new(
      start_date: @start_date,
      end_date: @end_date,
      daily_start_time: "09:00",
      daily_end_time: "12:00"
    ).call

    assert result.success?
    assert_equal 6, result.created_count
    assert_equal 0, result.skipped_count

    first_slot = AvailabilitySlot.order(:starts_at).first
    assert_equal Time.zone.parse("2026-06-10 09:00"), first_slot.starts_at
    assert_equal Time.zone.parse("2026-06-10 09:45"), first_slot.ends_at
    assert_equal Time.zone.parse("2026-06-11 11:00"), AvailabilitySlot.order(:starts_at).last.starts_at
  end

  test "skips existing slots instead of duplicating them" do
    AvailabilitySlot.create!(
      starts_at: Time.zone.parse("2026-06-10 09:00"),
      ends_at: Time.zone.parse("2026-06-10 09:45"),
      timezone: "Europe/Paris",
      colleague_name: "Équipe Le Bon Modèle",
      colleague_email: "contact@lebonmodele.com"
    )

    result = AvailabilitySlotBulkCreator.new(
      start_date: @start_date,
      end_date: @start_date,
      daily_start_time: "09:00",
      daily_end_time: "11:00"
    ).call

    assert result.success?
    assert_equal 1, result.created_count
    assert_equal 1, result.skipped_count
    assert_equal 2, AvailabilitySlot.count
  end

  test "returns errors for invalid date range" do
    result = AvailabilitySlotBulkCreator.new(
      start_date: @end_date,
      end_date: @start_date,
      daily_start_time: "09:00",
      daily_end_time: "12:00"
    ).call

    assert_not result.success?
    assert_includes result.errors, "La date de fin doit être après la date de début."
  end
end
