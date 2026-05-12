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
        redirect_to admin_packs_path, notice: "Pack mis a jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_pack
      @pack = Pack.find_by!(slug: params[:id])
    end

    def pack_params
      params.require(:pack).permit(:name, :objective, :description, :price_cents, :duration_minutes, :active)
    end
  end
end
