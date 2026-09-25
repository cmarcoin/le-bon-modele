class SiteCopy < ApplicationRecord
  GROUPS = {
    "home" => "Accueil",
    "about" => "Qui sommes-nous",
    "contact" => "Contact",
    "packs" => "Packs",
    "checkout" => "Tunnel d'achat"
  }.freeze

  validates :key, :label, :group, presence: true
  validates :key, uniqueness: true
  validates :group, inclusion: { in: GROUPS.keys }

  def self.fetch(key, default = "")
    find_by(key: key.to_s)&.value.presence || default.to_s
  end

  def self.seed!
    DEFAULTS.each do |attrs|
      record = find_or_initialize_by(key: attrs[:key])
      record.label = attrs[:label]
      record.group = attrs[:group]
      record.value = attrs[:value] if record.new_record? || record.value.blank?
      record.save!
    end
  end

  DEFAULTS = [
    { key: "home.hero_title", label: "Slogan", group: "home", value: "Choisissez la voiture qu’il vous faut. Pas celle qu’on cherche à vous vendre" },
    { key: "home.hero_subtitle", label: "Sous-titre", group: "home", value: "Bien acheter, c’est être bien conseillé. Avec Le Bon Modèle, deux experts indépendants vous accompagnent, pas à pas, pour choisir la voiture la plus adaptée à votre quotidien et à votre budget." },
    { key: "home.approach", label: "Notre approche", group: "home", value: "Sur le papier, acheter une voiture peut sembler simple.\nEn réalité, entre la multitude de marques et de modèles, de motorisations et d’options, d’annonces et de modes d’achat, c’est difficile de s’y retrouver.\nAvec Le Bon Modèle, on vous aide à y voir clair : de vrais conseillers vous guident pas à pas pour choisir et acheter la voiture la plus adaptée à votre quotidien et à votre budget, sans angles morts." },
    { key: "home.block_1_title", label: "Bloc 1 — titre", group: "home", value: "On est passés par là" },
    { key: "home.block_1_body", label: "Bloc 1 — texte", group: "home", value: "Derrière Le Bon Modèle, il n’y a pas d’IA, mais Charles et Jules : deux conducteurs qui savent par expérience à quel point acheter une voiture peut être complexe, et qui ont appris à comparer les offres, décrypter les prix et dénicher les bonnes affaires." },
    { key: "home.block_2_title", label: "Bloc 2 — titre", group: "home", value: "Conseillers indépendants" },
    { key: "home.block_2_body", label: "Bloc 2 — texte", group: "home", value: "Nous ne vendons pas de voitures. Nous ne prenons pas de commission. Notre métier, c’est de vous fournir un avis d’expert objectif, pour vous aider à faire un choix éclairé.\nEt notre seul client, c’est vous." },
    { key: "home.block_3_title", label: "Bloc 3 — titre", group: "home", value: "Double expertise" },
    { key: "home.block_3_body", label: "Bloc 3 — texte", group: "home", value: "Nous combinons une connaissance approfondie des véhicules avec une compréhension fine de vos besoins et de vos contraintes.\nNous appliquons une méthode rigoureuse et privilégions des échanges directs, au téléphone ou en visio, pour vous accompagner pas à pas." },
    { key: "about.hero_title", label: "Titre", group: "about", value: "De vrais conseillers, à vos côtés" },
    { key: "about.intro_title", label: "Titre d’intro", group: "about", value: "Derrière Le Bon Modèle, il y a nous, Charles et Jules" },
    { key: "about.intro_body", label: "Texte d’intro", group: "about", value: "Comme beaucoup d’automobilistes, nous sommes passés par là.\nDes heures à comparer des annonces, à hésiter entre plusieurs modèles, à essayer de comprendre ce qui justifie vraiment les écarts de prix. À se demander si l’on fait le bon choix… ou si l’on n’est pas en train de se faire avoir.\nSur le papier, acheter une voiture peut sembler simple. En réalité, entre la multitude de modèles, de motorisations, d’options, d’annonces et de modes d’achat, c’est difficile d’y voir clair.\nC’est pourquoi nous avons lancé Le Bon Modèle, un service d’accompagnement à l’achat automobile : de vrais conseillers vous guident pas à pas, au téléphone ou par visio, pour choisir et acheter la voiture la plus adaptée à votre quotidien et à votre budget." },
    { key: "about.independence", label: "Indépendance", group: "about", value: "Chez Le Bon Modèle, nous ne vendons pas de voitures. Notre métier, c’est de vous fournir un avis d’expert objectif, pour vous permettre de faire un choix éclairé.\nNous ne prenons pas non plus de commission sur un éventuel achat. Ce que nous vendons, c’est une expertise et des conseils. En tout indépendance." },
    { key: "about.method_title", label: "Titre méthode", group: "about", value: "Transformer une idée floue en un choix clair" },
    { key: "about.method_intro", label: "Intro méthode", group: "about", value: "Notre approche repose sur une double expertise : une connaissance fine des véhicules (modèles, motorisations, options, entretien, financement, modalités d’achat) et une compréhension concrète de votre quotidien (trajets, confort, praticité, stationnement, budget, vie de famille)." },
    { key: "contact.hero_title", label: "Titre", group: "contact", value: "Parlons de votre projet automobile" },
    { key: "contact.hero_subtitle", label: "Sous-titre", group: "contact", value: "Une question, un doute, un besoin précis ?" },
    { key: "contact.hero_body", label: "Texte d’intro", group: "contact", value: "On vous répond rapidement et clairement." },
    { key: "contact.phone_intro", label: "Texte Appelez-nous", group: "contact", value: "Échangez directement avec l’un de nos conseillers." },
    { key: "contact.phone_charles_label", label: "Nom conseiller 1", group: "contact", value: "Charles" },
    { key: "contact.phone_charles", label: "Téléphone conseiller 1", group: "contact", value: "" },
    { key: "contact.phone_jules_label", label: "Nom conseiller 2", group: "contact", value: "Jules" },
    { key: "contact.phone_jules", label: "Téléphone conseiller 2", group: "contact", value: "" }
  ].freeze
end
