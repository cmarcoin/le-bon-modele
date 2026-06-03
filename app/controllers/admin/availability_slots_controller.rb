module Admin
  class AvailabilitySlotsController < BaseController
    before_action :set_slot, only: %i[edit update destroy]

    def index
      @availability_slots = AvailabilitySlot.includes(:pack, :booking).order(starts_at: :desc)
    end

    def new
      @availability_slot = AvailabilitySlot.new(default_slot_attributes)
    end

    def create
      @availability_slot = AvailabilitySlot.new(slot_params)

      if @availability_slot.save
        redirect_to admin_availability_slots_path, notice: "Creneau ajoute."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @availability_slot.update(slot_params)
        redirect_to admin_availability_slots_path, notice: "Creneau mis a jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @availability_slot.booking.present?
        redirect_to admin_availability_slots_path, alert: "Ce creneau est reserve. Supprimez la reservation avant de supprimer le creneau."
        return
      end

      @availability_slot.destroy!
      redirect_to admin_availability_slots_path, notice: "Creneau supprime."
    end

    private

    def set_slot
      @availability_slot = AvailabilitySlot.find(params[:id])
    end

    def default_slot_attributes
      {
        timezone: AvailabilitySlot::DEFAULT_TIMEZONE,
        starts_at: Time.zone.tomorrow.change(hour: 10),
        ends_at: Time.zone.tomorrow.change(hour: 10, min: 45),
        colleague_name: "Charles Marcoin",
        colleague_email: "charles.marcoin@gmail.com"
      }
    end

    def slot_params
      params.require(:availability_slot).permit(:starts_at, :ends_at, :timezone, :colleague_name, :colleague_email, :pack_id, :active)
    end
  end
end
