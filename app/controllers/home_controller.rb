class HomeController < ApplicationController
  before_action :set_pack_catalog, only: %i[index starter_pack pack_premium]

  def index
  end

  def about
  end

  def faq
  end

  def starter_pack
  end

  def pack_premium
  end

  def contact
  end

  private

  def set_pack_catalog
    @starter_pack = Pack.find_by(slug: "starter-pack") || fallback_pack("starter-pack", "Starter pack", 5900, "/reference-assets/icons/starter-pack.svg", "text-brand-accent", "Identifier le modele qu'il vous faut")
    @premium_pack = Pack.find_by(slug: "pack-premium") || fallback_pack("pack-premium", "Pack Premium", 29900, "/reference-assets/icons/pack-premium.svg", "text-brand-coral", "Vous accompagner jusqu'a l'achat")
  end

  def fallback_pack(slug, name, price_cents, icon_path, accent_class, objective)
    Pack.new(slug:, name:, price_cents:, icon_path:, accent_class:, objective:, description: "", currency: "eur", duration_minutes: 45, active: true)
  end
end
