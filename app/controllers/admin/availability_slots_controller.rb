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

    def bulk_new
      @bulk_form = default_bulk_form_attributes
    end

    def bulk_create
      @bulk_form = bulk_form_params
      result = AvailabilitySlotBulkCreator.new(**bulk_creator_attributes).call

      if result.success?
        notice = "#{result.created_count} creneau(x) ajoute(s)."
        notice += " #{result.skipped_count} deja existant(s), ignores." if result.skipped_count.positive?
        redirect_to admin_availability_slots_path, notice: notice
      else
        @bulk_errors = result.errors
        render :bulk_new, status: :unprocessable_entity
      end
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

    def default_bulk_form_attributes
      {
        start_date: Date.tomorrow,
        end_date: Date.tomorrow + 6.days,
        daily_start_time: "09:00",
        daily_end_time: "18:00",
        timezone: AvailabilitySlot::DEFAULT_TIMEZONE,
        pack_id: nil
      }
    end

    def bulk_form_params
      permitted = params.require(:bulk_slot).permit(:start_date, :end_date, :daily_start_time, :daily_end_time, :timezone, :pack_id)

      begin
        permitted[:start_date] = Date.parse(permitted[:start_date]) if permitted[:start_date].present?
        permitted[:end_date] = Date.parse(permitted[:end_date]) if permitted[:end_date].present?
      rescue ArgumentError
        # Keep raw values; AvailabilitySlotBulkCreator will surface validation errors.
      end

      permitted
    end

    def bulk_creator_attributes
      {
        start_date: @bulk_form[:start_date],
        end_date: @bulk_form[:end_date],
        daily_start_time: @bulk_form[:daily_start_time],
        daily_end_time: @bulk_form[:daily_end_time],
        timezone: @bulk_form[:timezone].presence || AvailabilitySlot::DEFAULT_TIMEZONE,
        pack_id: @bulk_form[:pack_id]
      }
    end
  end
end
