module Admin
  class SiteCopiesController < BaseController
    before_action :set_site_copy, only: %i[edit update]

    def index
      SiteCopy.seed!
      @groups = SiteCopy.order(:group, :label).group_by(&:group)
    end

    def edit
    end

    def update
      if @site_copy.update(site_copy_params)
        redirect_to admin_site_copies_path, notice: "Texte mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_site_copy
      @site_copy = SiteCopy.find(params[:id])
    end

    def site_copy_params
      params.require(:site_copy).permit(:value)
    end
  end
end
