module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show destroy]

    def index
      @bookings = Booking.includes(:pack, :availability_slot, :payment_transaction).latest
    end

    def show
    end

    def destroy
      Booking.transaction do
        PaymentTransaction.where(booking_id: @booking.id).destroy_all
        @booking.reload.destroy!
      end

      redirect_to admin_bookings_path, notice: "Reservation supprimee."
    end

    private

    def set_booking
      @booking = Booking.includes(:pack, :availability_slot, :payment_transaction, :user).find(params[:id])
    end
  end
end
