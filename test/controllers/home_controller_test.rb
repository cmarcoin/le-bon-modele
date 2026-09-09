require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    Pack.find_or_create_by!(slug: "starter-pack") do |pack|
      pack.name = "Starter Pack"
      pack.objective = "Identifier le modèle qu'il vous faut"
      pack.description = "Starter description"
      pack.price_cents = 5_900
      pack.currency = "eur"
      pack.duration_minutes = 45
      pack.icon_path = "/reference-assets/icons/starter-pack.svg"
      pack.accent_class = "text-brand-accent"
    end

    Pack.find_or_create_by!(slug: "pack-premium") do |pack|
      pack.name = "Pack Premium"
      pack.objective = "Vous accompagner jusqu'à l'achat"
      pack.description = "Premium description"
      pack.price_cents = 29_900
      pack.currency = "eur"
      pack.duration_minutes = 45
      pack.icon_path = "/reference-assets/icons/pack-premium.svg"
      pack.accent_class = "text-brand-coral"
    end
  end

  test "serves the reference-inspired home page" do
    get root_path

    assert_response :success
    assert_select "h1", /Choisissez/
    assert_select "[data-controller~='budget']"
    assert_select "a", text: "Starter Pack"
    assert_select "a", text: "Pack Premium"
    starter = Pack.find_by!(slug: "starter-pack")
    assert_select "a[href='#{new_pack_booking_path(starter)}']"
  end

  test "serves the linked marketing pages" do
    {
      about_path => "Rendre l'achat auto lisible",
      faq_path => "Questions fréquentes",
      starter_pack_path => "Starter Pack",
      pack_premium_path => "Pack Premium",
      contact_path => "Vous êtes perdu"
    }.each do |path, heading|
      get path

      assert_response :success
      assert_select "body", /#{Regexp.escape(heading)}/
    end
  end

  test "starter pack page follows the four-step layout" do
    starter = Pack.find_by!(slug: "starter-pack")

    get starter_pack_path

    assert_response :success
    assert_select "h2", text: "Votre accompagnement en 4 étapes"
    assert_select "h3", text: "Questionnaire préparatoire"
    assert_select "h3", text: "Premier entretien avec Charles et Jules"
    assert_select "h3", text: "Liste réduite de 2 à 3 modèles"
    assert_select "h3", text: "Entretien de suivi avec Charles et Jules"
    assert_select ".starter-pack-duration", text: /60 min/
    assert_select ".starter-pack-duration", text: /30 min/
    assert_select "p", text: "On clarifie vos vrais besoins"
    assert_select "strong", text: "Nous transformons une idée floue en choix clair"
    assert_select "img[src='/reference-assets/starter-pack-illustration.png']"
    assert_select "a[href='#{new_pack_booking_path(starter)}']", text: "Je choisis cette offre"
  end

  test "pack premium page follows the two-phase layout" do
    premium = Pack.find_by!(slug: "pack-premium")

    get pack_premium_path

    assert_response :success
    assert_select "h2", text: "Votre accompagnement en 2 grandes phases"
    assert_select "h3", text: "Phase 1 — Choisir le bon modèle"
    assert_select "h3", text: "Phase 2 — Trouver la meilleure offre"
    assert_select "h4", text: "Questionnaire préparatoire"
    assert_select "h4", text: "Entretien n°1 avec Charles et Jules"
    assert_select "h4", text: "Liste réduite de 2 à 3 modèles"
    assert_select "h4", text: "Entretien n°2 avec Charles et Jules"
    assert_select "h4", text: "Recherche, tri et analyse des offres"
    assert_select "h4", text: "Entretien n°3 avec Charles et Jules"
    assert_select ".starter-pack-duration", text: /60 min/
    assert_select "p", text: "On définit le modèle et les équipements qu’il vous faut"
    assert_select "strong", text: "La jungle des annonces, c’est notre problème, plus le vôtre"
    assert_select "img[src='/reference-assets/pack-premium-illustration.png']"
    assert_select "a[href='#{new_pack_booking_path(premium)}']", text: "Je choisis cette offre"
  end
end
