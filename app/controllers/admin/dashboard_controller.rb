module Admin
  class DashboardController < BaseController
    def index
      @packs = Pack.order(:name)
      @upcoming_slots = AvailabilitySlot.includes(:pack).upcoming.order(:starts_at).limit(8)
      @recent_bookings = Booking.includes(:pack, :availability_slot, :user).latest.limit(8)
    end
  end
end
