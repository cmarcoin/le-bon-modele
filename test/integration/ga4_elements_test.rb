require "test_helper"

class Ga4ElementsTest < ActionDispatch::IntegrationTest
  test "ga4-purchase element renders only for paid bookings" do
    pack = Pack.find_by(name: "Pack Conseil") || Pack.create!(
      name: "Pack Conseil",
      price_cents: 9900,
      description: "Test"
    )
    
    slot = AvailabilitySlot.create!(
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 1.hour
    )
    
    # Create paid booking
    paid_booking = Booking.create!(
      pack: pack,
      availability_slot: slot,
      first_name: "Test",
      last_name: "User",
      email: "paid@example.com",
      phone: "0123456789",
      meeting_mode: "visio",
      amount_cents: 9900,
      status: "paid"
    )
    
    # Visit with paid booking (session_id would trigger lookup)
    get checkout_success_path, params: { session_id: paid_booking.stripe_session_id || "test_paid" }
    
    # Check response includes paid state indicators
    assert_response :success
    assert_match /C'est réservé !/, response.body
    assert_match /data-controller="ga4-purchase"/, response.body
    
    # Create unpaid booking
    unpaid_booking = Booking.create!(
      pack: pack,
      availability_slot: slot,
      first_name: "Test",
      last_name: "User2",
      email: "unpaid@example.com",
      phone: "0123456789",
      meeting_mode: "visio",
      amount_cents: 9900,
      status: "pending"
    )
    
    # Visit with unpaid booking
    get checkout_success_path, params: { session_id: unpaid_booking.stripe_session_id || "test_unpaid" }
    
    # Check response includes unpaid state indicators
    assert_response :success
    assert_match /Paiement reçu !/, response.body
    # Should NOT include ga4-purchase element
    assert_no_match /data-controller="ga4-purchase"/, response.body
  end
  
  test "ga4-lead element renders only after successful contact submission" do
    # Initial visit - no flash message
    get contact_path
    assert_response :success
    # Should NOT include ga4-lead element
    assert_no_match /data-controller="ga4-lead"/, response.body
    
    # Submit contact form
    post submit_contact_path, params: {
      contact_inquiry: {
        first_name: "Test",
        last_name: "User",
        email: "test@example.com",
        message: "Test message"
      }
    }
    
    # Follow redirect if any
    follow_redirect! if response.redirect?
    
    # After successful submission with flash message, ga4-lead should be present
    assert_response :success
    assert_match /data-controller="ga4-lead"/, response.body
  end
end
