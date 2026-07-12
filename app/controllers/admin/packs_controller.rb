module Admin
  class PacksController < BaseController
    before_action :set_pack, only: %i[edit update sync_stripe]

    def index
      @packs = Pack.order(:name)
    end

    def edit
    end

    def update
      if @pack.update(pack_params)
        sync_pack!(@pack)
        redirect_to admin_packs_path, notice: "Pack mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    rescue StripePackSync::Error => error
      @pack.errors.add(:base, error.message)
      render :edit, status: :unprocessable_entity
    end

    def sync_stripe
      packs = @pack.present? ? [ @pack ] : Pack.order(:name)
      synced_slugs = sync_packs!(packs)

      redirect_to admin_packs_path, notice: sync_notice(synced_slugs)
    rescue StripePackSync::Error => error
      redirect_to admin_packs_path, alert: error.message
    end

    private

    def set_pack
      @pack = Pack.find_by!(slug: params[:id]) if params[:id].present?
    end

    def pack_params
      params.require(:pack).permit(:name, :objective, :description, :price_cents, :duration_minutes, :active)
    end

    def sync_pack!(pack)
      return unless stripe_configured?

      StripePackSync.sync!(pack)
    end

    def sync_packs!(packs)
      raise StripePackSync::ConfigurationError, "STRIPE_SECRET_KEY est manquant." unless stripe_configured?

      packs.map do |pack|
        StripePackSync.sync!(pack)
        pack.slug
      end
    end

    def stripe_configured?
      ENV["STRIPE_SECRET_KEY"].present?
    end

    def sync_notice(slugs)
      if slugs.one?
        "#{slugs.first} synchronisé avec Stripe."
      else
        "#{slugs.size} packs synchronisés avec Stripe : #{slugs.join(', ')}."
      end
    end
  end
end
