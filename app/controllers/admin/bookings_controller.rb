module Admin
  class BookingsController < BaseController
    def index
      @bookings = Booking.includes(:pack, :availability_slot, :payment_transaction).latest
    end

    def show
      @booking = Booking.includes(:pack, :availability_slot, :payment_transaction, :user).find(params[:id])
    end
  end
end
