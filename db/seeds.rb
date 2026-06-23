# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
Pack.find_or_create_by!(slug: "starter-pack") do |pack|
  pack.name = "Starter pack"
  pack.objective = "Identifier le modèle qu'il vous faut"
  pack.description = "Passez 90 min avec nos deux experts auto pour identifier le bon modèle de voiture à acheter, celui qui correspond vraiment à vos besoins, vos contraintes et votre budget."
  pack.price_cents = 5_900
  pack.currency = "eur"
  pack.duration_minutes = 45
  pack.icon_path = "/reference-assets/icons/starter-pack.svg"
  pack.accent_class = "text-brand-accent"
  pack.active = true
end

Pack.find_or_create_by!(slug: "pack-premium") do |pack|
  pack.name = "Pack Premium"
  pack.objective = "Vous accompagner jusqu'à l'achat"
  pack.description = "Du cadrage de votre besoin jusqu'à l'achat de votre voiture, nos deux experts auto vous accompagnent à chaque étape."
  pack.price_cents = 29_900
  pack.currency = "eur"
  pack.duration_minutes = 45
  pack.icon_path = "/reference-assets/icons/pack-premium.svg"
  pack.accent_class = "text-brand-coral"
  pack.active = true
end

if ENV["STRIPE_SECRET_KEY"].present?
  Pack.find_each do |pack|
    StripePackSync.sync!(pack)
    puts "Stripe synchronisé pour #{pack.slug}"
  end
end

if ENV["ADMIN_INITIAL_PASSWORD"].present?
  User::ADMIN_EMAILS.each do |email|
    User.find_or_create_by!(email:) do |user|
      user.name = email.split("@").first.tr(".", " ").titleize
      user.role = "admin"
      user.password = ENV.fetch("ADMIN_INITIAL_PASSWORD")
    end
  end
end
