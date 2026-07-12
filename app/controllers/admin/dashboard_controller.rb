module Admin
  class DashboardController < BaseController
    def index
      @packs = Pack.order(:name)
      @upcoming_slots = AvailabilitySlot.includes(:pack).upcoming.order(:starts_at).limit(8)
      @recent_bookings = Booking.includes(:pack, :availability_slot, :user).latest.limit(8)
      @pending_payment_count = Booking.pending_payment.count
      @pending_payment_bookings = Booking.pending_payment.includes(:pack, :availability_slot).latest.limit(5)
    end
  end
end
