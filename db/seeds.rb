# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
starter = Pack.find_or_initialize_by(slug: "starter-pack")
starter.assign_attributes(
  name: "Pack Conseil",
  objective: "Identifier le modèle qu'il vous faut",
  description: "Passez 90 min avec nos deux experts auto pour identifier le bon modèle de voiture à acheter, celui qui correspond vraiment à vos besoins, vos contraintes et votre budget.",
  includes_text: [
    "Un questionnaire préparatoire",
    "Un premier entretien de 60 minutes avec Charles et Jules",
    "Un document de synthèse et une pré-sélection de modèles",
    "Un entretien de suivi, de 30 minutes"
  ].join("\n"),
  price_cents: 5_900,
  currency: "eur",
  duration_minutes: 45,
  icon_path: "/reference-assets/icons/starter-pack.svg",
  accent_class: "text-brand-primary",
  active: true
)
starter.save!

premium = Pack.find_or_initialize_by(slug: "pack-premium")
premium.assign_attributes(
  name: "Pack Achat",
  objective: "Vous accompagner jusqu'à l'achat",
  description: "Du cadrage de votre besoin jusqu'à l'achat de votre voiture, nos deux experts auto vous accompagnent à chaque étape.",
  includes_text: [
    "Un questionnaire préparatoire",
    "Trois entretiens, de 60 minutes chacun, avec Charles et Jules",
    "Un document de synthèse avec une présélection de 2 à 3 modèles",
    "Une sélection de 4 à 5 annonces avec un comparatif détaillé",
    "Un accompagnement pour répondre à vos questions entre les rendez-vous"
  ].join("\n"),
  price_cents: 29_900,
  currency: "eur",
  duration_minutes: 45,
  icon_path: "/reference-assets/icons/pack-premium.svg",
  accent_class: "text-brand-primary",
  active: true
)
premium.save!

SiteCopy.seed!

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
