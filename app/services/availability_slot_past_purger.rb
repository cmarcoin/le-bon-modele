class AvailabilitySlotPastPurger
  Result = Struct.new(:deleted_count, keyword_init: true)

  def call
    deleted = 0

    AvailabilitySlot.past.unbooked.find_each do |slot|
      next if slot.active_booking.present?

      AvailabilitySlot.transaction do
        slot.bookings.where(status: "canceled").find_each do |booking|
          PaymentTransaction.where(booking_id: booking.id).destroy_all
          booking.destroy!
        end

        slot.destroy!
      end

      deleted += 1
    end

    Result.new(deleted_count: deleted)
  end
end
