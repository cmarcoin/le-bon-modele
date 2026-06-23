import { Controller } from "@hotwired/stimulus"

const OFFERS = {
  purchase: {
    min: 5000,
    max: 20000,
    step: 5000,
    unit: "€",
    values: {
      5000: [
        ["Citadine Compacte", "Petite citadine économique, idéale pour la ville. Kilométrage moyen, entretien régulier.", "80 000 - 120 000 km", "2005 - 2010", "5000€", "/reference-assets/modeles/citadine.png"],
        ["Monospace Ancien", "Version familiale accessible pour petit budget.", "150 000 - 200 000 km", "2005 - 2010", "5000€", "/reference-assets/modeles/monospace-ancien.png"],
        ["Berline d'Entrée de Gamme", "Berline basique, fiable et économique. Parfaite pour les trajets quotidiens.", "120 000 - 160 000 km", "2012 - 2016", "5000€", "/reference-assets/modeles/berline-base.png"],
        ["SUV Compact Ancien", "SUV ancien accessible avec position de conduite haute.", "80 000 - 120 000 km", "2010 - 2014", "5000€", "/reference-assets/modeles/suv-ancien.png"]
      ],
      10000: [
        ["Citadine récente", "Citadine moderne, faible coût d’usage et équipement plus confortable.", "50 000 - 90 000 km", "2015 - 2018", "10 000€", "/reference-assets/modeles/citadine-recente.png"],
        ["Break compact", "Format polyvalent pour famille ou longs trajets.", "90 000 - 140 000 km", "2013 - 2017", "10 000€", "/reference-assets/modeles/break.png"],
        ["SUV urbain", "Position de conduite haute, gabarit compact, usage quotidien facile.", "100 000 - 140 000 km", "2014 - 2017", "10 000€", "/reference-assets/modeles/suv-urbain.png"],
        ["Berline confort", "Bonne routière, idéale pour les trajets réguliers avec plus de confort.", "110 000 - 150 000 km", "2014 - 2018", "10 000€", "/reference-assets/modeles/berline-confort.png"]
      ],
      15000: [
        ["Compacte bien équipée", "Bon équilibre entre modernité, équipements et coût global.", "40 000 - 80 000 km", "2017 - 2020", "15 000€", "/reference-assets/modeles/compacte.png"],
        ["SUV compact récent", "Polyvalent, rassurant et adapté à un usage familial modéré.", "60 000 - 100 000 km", "2018 - 2020", "15 000€", "/reference-assets/modeles/suv-compact.png"],
        ["Monospace récent", "Grand volume intérieur et vraie praticité pour les familles.", "70 000 - 110 000 km", "2016 - 2019", "15 000€", "/reference-assets/modeles/monospace-recent.png"],
        ["Break routier", "Parfait pour avaler les kilomètres avec coffre généreux.", "80 000 - 120 000 km", "2017 - 2020", "15 000€", "/reference-assets/modeles/break-routier.png"]
      ],
      20000: [
        ["SUV familial", "Compromis solide entre espace, image et polyvalence.", "40 000 - 80 000 km", "2019 - 2022", "20 000€", "/reference-assets/modeles/suv-familial.png"],
        ["Berline récente", "Confort de route supérieur avec motorisations plus modernes.", "35 000 - 75 000 km", "2019 - 2022", "20 000€", "/reference-assets/modeles/berline-recente.png"],
        ["Compacte premium", "Finition plus valorisante et équipements plus complets.", "45 000 - 85 000 km", "2018 - 2021", "20 000€", "/reference-assets/modeles/compacte-premium.png"],
        ["Break moderne", "Solution idéale pour ceux qui veulent du coffre sans SUV.", "50 000 - 90 000 km", "2019 - 2022", "20 000€", "/reference-assets/modeles/break-moderne.png"]
      ]
    }
  },
  leasing: {
    min: 100,
    max: 300,
    step: 100,
    unit: "€/mois",
    values: {
      100: [
        ["Citadine LOA économique", "Petit budget mensuel pour accéder à une voiture récente.", "Très faible", "Récent", "100€/mois", "/reference-assets/modeles/loa-citadine.png"],
        ["Compacte LOA", "Solution simple pour un usage quotidien sans gros achat initial.", "Très faible", "Récent", "100€/mois", "/reference-assets/modeles/loa-compacte.png"],
        ["SUV urbain LOA", "Format compact avec l’avantage d’un véhicule récent.", "Très faible", "Récent", "100€/mois", "/reference-assets/modeles/loa-suv.png"],
        ["Hybride compacte LOA", "Accès plus facile à une motorisation moderne.", "Très faible", "Récent", "100€/mois", "/reference-assets/modeles/loa-hybride.png"]
      ],
      200: [
        ["SUV compact LOA", "Mensualité plus confortable pour viser une voiture mieux équipée.", "Très faible", "Récent", "200€/mois", "/reference-assets/modeles/loa-suv-compact.png"],
        ["Berline récente LOA", "Confort supérieur avec budget mensuel maîtrisé.", "Très faible", "Récent", "200€/mois", "/reference-assets/modeles/loa-berline.png"],
        ["Break familial LOA", "Bon compromis famille / budget sans achat direct.", "Très faible", "Récent", "200€/mois", "/reference-assets/modeles/loa-break.png"],
        ["Hybride LOA", "Accès à une solution plus moderne avec mensualité intermédiaire.", "Très faible", "Récent", "200€/mois", "/reference-assets/modeles/loa-hybride-2.png"]
      ],
      300: [
        ["SUV récent LOA +", "Mensualité plus haute pour un modèle plus récent et mieux fini.", "Très faible", "Récent", "300€/mois", "/reference-assets/modeles/loa-suv-plus.png"],
        ["Grande compacte LOA", "Plus d’équipement et de choix de finitions.", "Très faible", "Récent", "300€/mois", "/reference-assets/modeles/loa-grande-compacte.png"],
        ["Familiale moderne LOA", "Bonne solution pour passer sur une voiture récente sans achat total.", "Très faible", "Récent", "300€/mois", "/reference-assets/modeles/loa-familiale.png"],
        ["Hybride bien équipée LOA", "Niveau de finition plus élevé avec meilleur lissage budgétaire.", "Très faible", "Récent", "300€/mois", "/reference-assets/modeles/loa-hybride-premium.png"]
      ]
    }
  }
}

export default class extends Controller {
  static targets = ["cards", "range", "modeToggle", "modeKnob", "purchaseLabel", "leasingLabel", "minLabel", "maxLabel", "currentLabel"]

  connect() {
    this.mode = "purchase"
    this.updateMode()
  }

  toggle() {
    this.mode = this.mode === "purchase" ? "leasing" : "purchase"
    this.updateMode()
  }

  showPurchase() {
    this.mode = "purchase"
    this.updateMode()
  }

  showLeasing() {
    this.mode = "leasing"
    this.updateMode()
  }

  rangeChanged() {
    this.updateTrack()
    this.renderCards()
  }

  updateMode() {
    const config = this.config
    this.rangeTarget.min = config.min
    this.rangeTarget.max = config.max
    this.rangeTarget.step = config.step
    this.rangeTarget.value = config.min
    this.modeToggleTarget.setAttribute("aria-pressed", String(this.mode === "leasing"))
    this.modeKnobTarget.style.transform = this.mode === "leasing" ? "translateX(120px)" : "translateX(0)"
    this.purchaseLabelTarget.classList.toggle("opacity-50", this.mode === "leasing")
    this.leasingLabelTarget.classList.toggle("opacity-50", this.mode !== "leasing")
    this.updateTrack()
    this.renderCards()
  }

  updateTrack() {
    const min = Number(this.rangeTarget.min)
    const max = Number(this.rangeTarget.max)
    const value = Number(this.rangeTarget.value)
    const progress = ((value - min) / (max - min)) * 100
    this.rangeTarget.style.setProperty("--progress", `${progress}%`)
    this.minLabelTarget.textContent = this.format(configFor(this.mode).min)
    this.maxLabelTarget.textContent = this.format(configFor(this.mode).max)
    this.currentLabelTarget.textContent = this.format(value)
  }

  renderCards() {
    const value = Number(this.rangeTarget.value)
    const cards = this.config.values[value] || []

    if (cards.length === 0) {
      this.cardsTarget.innerHTML = `
        <div class="col-span-full rounded-brand border border-brand-border bg-white p-10 text-center shadow-brand">
          <p class="text-2xl font-bold text-brand-primary">Aucune offre disponible pour ce palier</p>
          <p class="mt-3 text-brand-text-secondary">Ajoute les modèles correspondant à cette tranche.</p>
        </div>
      `
      return
    }

    this.cardsTarget.innerHTML = cards.map((card) => this.cardTemplate(card, value)).join("")
  }

  cardTemplate([title, description, mileage, year, price, image]) {
    return `
      <article class="flex h-full flex-col overflow-hidden rounded-brand border border-brand-border bg-white text-left shadow-brand">
        <div class="flex h-52 w-full shrink-0 items-center justify-center bg-brand-beige p-6">
          <img
            src="${image}"
            alt="${title}"
            class="h-full w-auto object-contain"
            onerror="this.style.display='none'; this.parentElement.innerHTML='<div class=&quot;flex h-full items-center justify-center text-brand-text-secondary&quot;>Image manquante</div>';"
          />
        </div>
        <div class="flex flex-grow flex-col p-4">
          <h3 class="text-[24px] font-bold leading-tight text-brand-text">${title}</h3>
          <p class="mt-3 text-[16px] leading-relaxed text-brand-text-secondary">${description}</p>
          <div class="mt-4 flex flex-row items-center gap-8">
            <div class="flex items-center gap-2">
              <img src="/reference-assets/icons/kilo.svg" alt="Icone roue" class="h-6 w-6 shrink-0">
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Kilométrage</span>
                <span class="text-xs text-brand-text-secondary">${mileage}</span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <img src="/reference-assets/icons/annee.svg" alt="Icone volant" class="h-6 w-6 shrink-0">
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Année</span>
                <span class="text-xs text-brand-text-secondary">${year}</span>
              </div>
            </div>
          </div>
          <p class="mt-auto pt-6 text-[24px] text-brand-text">Prix : <span class="font-bold">${price}</span></p>
        </div>
      </article>
    `
  }

  format(value) {
    return `${value}${this.config.unit}`
  }

  get config() {
    return configFor(this.mode)
  }
}

function configFor(mode) {
  return OFFERS[mode]
}
