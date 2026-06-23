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
    @contact_inquiry = ContactInquiry.new
  end

  def submit_contact
    @contact_inquiry = ContactInquiry.new(contact_inquiry_params)

    if @contact_inquiry.valid?
      ContactMailer.inquiry(@contact_inquiry).deliver_later
      redirect_to contact_path, notice: "Merci, votre message a bien été envoyé. Nous vous répondrons rapidement."
    else
      flash.now[:alert] = "Veuillez corriger les champs indiqués."
      render :contact, status: :unprocessable_entity
    end
  end

  private

  def contact_inquiry_params
    params.require(:contact_inquiry).permit(:first_name, :email, :message, :company)
  end

  def set_pack_catalog
    @starter_pack = Pack.find_by(slug: "starter-pack") || fallback_pack("starter-pack", "Starter pack", 5900, "/reference-assets/icons/starter-pack.svg", "text-brand-accent", "Identifier le modèle qu'il vous faut")
    @premium_pack = Pack.find_by(slug: "pack-premium") || fallback_pack("pack-premium", "Pack Premium", 29900, "/reference-assets/icons/pack-premium.svg", "text-brand-coral", "Vous accompagner jusqu'à l'achat")
  end

  def fallback_pack(slug, name, price_cents, icon_path, accent_class, objective)
    Pack.new(slug:, name:, price_cents:, icon_path:, accent_class:, objective:, description: "", currency: "eur", duration_minutes: 45, active: true)
  end
end
