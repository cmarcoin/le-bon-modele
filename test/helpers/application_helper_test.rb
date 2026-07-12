require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

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
      starts_at: Time.zone.parse("2026-07-15 10:00"),
      ends_at: Time.zone.parse("2026-07-15 10:45"),
      timezone: "Europe/Paris"
    )
    @booking = Booking.create!(
      user: users(:client),
      pack: @pack,
      availability_slot: @slot,
      customer_name: "Jean Dupont",
      customer_email: "jean@example.com",
      customer_phone: "0612345678",
      amount_cents: 5_900,
      currency: "eur",
      status: "paid"
    )
  end

  test "google_calendar_url_for builds a pre-filled google calendar link" do
    url = google_calendar_url_for(@booking)

    assert_includes url, "https://calendar.google.com/calendar/render?"
    assert_includes url, CGI.escape("Starter Pack — Jean Dupont")
    assert_includes url, "dates=20260715T100000%2F20260715T104500"
    assert_includes url, "ctz=Europe%2FParis"
    assert_includes url, CGI.escape("Client : Jean Dupont")
    assert_includes url, CGI.escape("jean@example.com")
  end
end
