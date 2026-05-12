import { Controller } from "@hotwired/stimulus"

const OFFERS = {
  purchase: {
    min: 5000,
    max: 50000,
    step: 5000,
    unit: "€",
    values: {
      5000: [
        ["Citadine compacte", "Petite citadine economique, ideale pour la ville.", "80 000 - 120 000 km", "2005 - 2010"],
        ["Monospace ancien", "Version familiale accessible pour petit budget.", "150 000 - 200 000 km", "2005 - 2010"],
        ["Berline d'entree", "Berline basique, fiable et economique.", "120 000 - 160 000 km", "2012 - 2016"],
        ["SUV compact ancien", "Position de conduite haute avec prix contenu.", "80 000 - 120 000 km", "2010 - 2014"]
      ],
      10000: [
        ["Citadine recente", "Faible cout d'usage et equipement plus confortable.", "50 000 - 90 000 km", "2015 - 2018"],
        ["Break compact", "Format polyvalent pour famille ou longs trajets.", "90 000 - 140 000 km", "2013 - 2017"],
        ["SUV urbain", "Gabarit compact, usage quotidien facile.", "100 000 - 140 000 km", "2014 - 2017"],
        ["Berline confort", "Bonne routiere pour trajets reguliers.", "110 000 - 150 000 km", "2014 - 2018"]
      ],
      15000: [
        ["Compacte equipee", "Bon equilibre entre modernite et cout global.", "40 000 - 80 000 km", "2017 - 2020"],
        ["SUV compact recent", "Polyvalent et adapte a un usage familial.", "60 000 - 100 000 km", "2018 - 2020"],
        ["Monospace recent", "Grand volume interieur et vraie praticite.", "70 000 - 110 000 km", "2016 - 2019"],
        ["Break routier", "Parfait pour avaler les kilometres.", "80 000 - 120 000 km", "2017 - 2020"]
      ],
      20000: [
        ["SUV familial", "Compromis solide entre espace et polyvalence.", "40 000 - 80 000 km", "2019 - 2022"],
        ["Berline recente", "Confort superieur avec motorisations modernes.", "35 000 - 75 000 km", "2019 - 2022"],
        ["Compacte premium", "Finition valorisante et equipements complets.", "45 000 - 85 000 km", "2018 - 2021"],
        ["Break moderne", "Du coffre sans passer au SUV.", "50 000 - 90 000 km", "2019 - 2022"]
      ]
    }
  },
  leasing: {
    min: 100,
    max: 1000,
    step: 100,
    unit: "€/mois",
    values: {
      100: [
        ["Citadine LOA", "Petit budget mensuel pour une voiture recente.", "Tres faible", "Recent"],
        ["Compacte LOA", "Solution simple pour un usage quotidien.", "Tres faible", "Recent"],
        ["SUV urbain LOA", "Format compact avec vehicule recent.", "Tres faible", "Recent"],
        ["Hybride compacte", "Acces facilite a une motorisation moderne.", "Tres faible", "Recent"]
      ],
      200: [
        ["SUV compact LOA", "Mensualite confortable pour viser mieux equipe.", "Tres faible", "Recent"],
        ["Berline recente LOA", "Confort superieur avec budget mensuel maitrise.", "Tres faible", "Recent"],
        ["Break familial LOA", "Bon compromis famille et budget.", "Tres faible", "Recent"],
        ["Hybride LOA", "Solution moderne avec mensualite intermediaire.", "Tres faible", "Recent"]
      ],
      300: [
        ["SUV recent LOA +", "Modele plus recent et mieux fini.", "Tres faible", "Recent"],
        ["Grande compacte LOA", "Plus d'equipement et de choix de finitions.", "Tres faible", "Recent"],
        ["Familiale moderne", "Voiture recente sans achat total.", "Tres faible", "Recent"],
        ["Hybride equipee", "Meilleur lissage budgetaire.", "Tres faible", "Recent"]
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
          <p class="mt-3 text-brand-text-secondary">Nous ajoutons progressivement des exemples pour cette tranche.</p>
        </div>
      `
      return
    }

    this.cardsTarget.innerHTML = cards.map((card) => this.cardTemplate(card, value)).join("")
  }

  cardTemplate([title, description, mileage, year], value) {
    return `
      <article class="flex h-full flex-col overflow-hidden rounded-brand border border-brand-border bg-white text-left shadow-brand">
        <div class="car-card-visual" aria-hidden="true"><span></span></div>
        <div class="flex flex-grow flex-col p-4">
          <h3 class="text-[24px] font-bold leading-tight text-brand-text">${title}</h3>
          <p class="mt-3 text-[16px] leading-relaxed text-brand-text-secondary">${description}</p>
          <div class="mt-4 flex flex-row items-center gap-8">
            <div class="flex items-center gap-2">
              <span class="spec-icon-wrap">km</span>
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Kilometrage</span>
                <span class="text-xs text-brand-text-secondary">${mileage}</span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span class="spec-icon-wrap">an</span>
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Annee</span>
                <span class="text-xs text-brand-text-secondary">${year}</span>
              </div>
            </div>
          </div>
          <p class="mt-auto pt-6 text-[24px] text-brand-text">Prix : <span class="font-bold">${this.format(value)}</span></p>
        </div>
      </article>
    `
  }

  format(value) {
    return `${new Intl.NumberFormat("fr-FR").format(value)}${this.config.unit}`
  }

  get config() {
    return configFor(this.mode)
  }
}

function configFor(mode) {
  return OFFERS[mode]
}
