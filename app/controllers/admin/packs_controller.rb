module Admin
  class PacksController < BaseController
    before_action :set_pack, only: %i[edit update]

    def index
      @packs = Pack.order(:name)
    end

    def edit
    end

    def update
      if @pack.update(pack_params)
        sync_pack_to_stripe!
        redirect_to admin_packs_path, notice: "Pack mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    rescue StripePackSync::Error => error
      @pack.errors.add(:base, error.message)
      render :edit, status: :unprocessable_entity
    end

    private

    def set_pack
      @pack = Pack.find_by!(slug: params[:id])
    end

    def pack_params
      params.require(:pack).permit(:name, :objective, :description, :price_cents, :duration_minutes, :active)
    end

    def sync_pack_to_stripe!
      return unless ENV["STRIPE_SECRET_KEY"].present?

      StripePackSync.sync!(@pack)
    end
  end
end
