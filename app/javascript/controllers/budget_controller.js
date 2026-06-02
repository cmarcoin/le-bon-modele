import { Controller } from "@hotwired/stimulus"

const OFFERS = {
  "achat": {
    "min": 5000,
    "max": 50000,
    "step": 5000,
    "unit": "€",
    "values": {
      "5000": [
        {
          "title": "Citadine Compacte",
          "description": "Petite citadine économique, idéale pour la ville. Kilométrage moyen, entretien régulier.",
          "mileage": "80 000 - 120 000 km",
          "year": "2005 - 2010",
          "price": "5000€",
          "image": "/reference-assets/modeles/5000/citadine.png"
        },
        {
          "title": "Monospace Ancien",
          "description": "Version familiale accessible pour petit budget.",
          "mileage": "150 000 - 200 000 km",
          "year": "2005 - 2010",
          "price": "5000€",
          "image": "/reference-assets/modeles/5000/monospace-ancien.png"
        },
        {
          "title": "Berline d'Entrée de Gamme",
          "description": "Berline basique, fiable et économique. Parfaite pour les trajets quotidiens.",
          "mileage": "120 000 - 160 000 km",
          "year": "2012 - 2016",
          "price": "5000€",
          "image": "/reference-assets/modeles/5000/berline-base.png"
        },
        {
          "title": "SUV Compact Ancien",
          "description": "SUV ancien accessible avec position de conduite haute.",
          "mileage": "80 000 - 120 000 km",
          "year": "2010 - 2014",
          "price": "5000€",
          "image": "/reference-assets/modeles/5000/suv-ancien.png"
        }
      ],
      "10000": [
        {
          "title": "Citadine récente",
          "description": "Citadine moderne, faible coût d’usage et équipement plus confortable.",
          "mileage": "50 000 - 90 000 km",
          "year": "2015 - 2018",
          "price": "10 000€",
          "image": "/reference-assets/modeles/10000/citadine-recente.png"
        },
        {
          "title": "Monospace Familial",
          "description": "Monospace familial spacieux, idéal pour les familles nombreuses. Kilométrage raisonnable.",
          "mileage": "80 000 - 120 000 km",
          "year": "2014 - 2018",
          "price": "10 000€",
          "image": "/reference-assets/modeles/10000/monospace-familial.png"
        },
        {
          "title": "Berline Confortable",
          "description": "Berline confortable avec bon équipement. Parfaite pour les longs trajets.",
          "mileage": "60 000 - 100 000 km",
          "year": "2015 - 2019",
          "price": "10 000€",
          "image": "/reference-assets/modeles/10000/berline-confort.png"
        },
        {
          "title": "SUV Compact Récent",
          "description": "SUV compact plus récent, bon compromis entre espace et consommation.",
          "mileage": "70 000 - 110 000 km",
          "year": "2016 - 2020",
          "price": "10 000€",
          "image": "/reference-assets/modeles/10000/suv-compact-recent.png"
        }
      ],
      "15000": [
        {
          "title": "Citadine Premium",
          "description": "Citadine haut de gamme avec équipements modernes. Faible kilométrage.",
          "mileage": "30 000 - 60 000 km",
          "year": "2019 - 2021",
          "price": "15 000€",
          "image": "/reference-assets/modeles/15000/citadine-premium.png"
        },
        {
          "title": "Monospace Premium",
          "description": "Monospace haut de gamme, très spacieux et bien équipé. Idéal pour grandes familles.",
          "mileage": "50 000 - 80 000 km",
          "year": "2018 - 2021",
          "price": "15 000€",
          "image": "/reference-assets/modeles/15000/monospace-premium.png"
        },
        {
          "title": "Berline Premium",
          "description": "Berline premium avec équipements haut de gamme. Confort et sécurité optimaux.",
          "mileage": "40 000 - 70 000 km",
          "year": "2019 - 2022",
          "price": "15 000€",
          "image": "/reference-assets/modeles/15000/berline-premium.png"
        },
        {
          "title": "SUV Milieu de Gamme",
          "description": "SUV spacieux et confortable, bon équipement. Parfait pour famille et loisirs.",
          "mileage": "50 000 - 85 000 km",
          "year": "2018 - 2021",
          "price": "15 000€",
          "image": "/reference-assets/modeles/15000/suv-gamme.png"
        }
      ],
      "20000": [
        {
          "title": "Citadine Électrique",
          "description": "Citadine électrique récente, économique et écologique. Autonomie adaptée à la ville.",
          "mileage": "20 000 - 50 000 km",
          "year": "2020 - 2023",
          "price": "20 000€",
          "image": "/reference-assets/modeles/20000/citadine-elec.png"
        },
        {
          "title": "Monospace Luxe",
          "description": "Monospace haut de gamme avec équipements premium. Espace et confort maximaux.",
          "mileage": "30 000 - 60 000 km",
          "year": "2020 - 2023",
          "price": "20 000€",
          "image": "/reference-assets/modeles/20000/mono-luxe.png"
        },
        {
          "title": "Berline Luxe",
          "description": "Berline de luxe avec finition premium. Confort, sécurité et technologie de pointe.",
          "mileage": "25 000 - 55 000 km",
          "year": "2021 - 2023",
          "price": "20 000€",
          "image": "/reference-assets/modeles/20000/berline-luxe.png"
        },
        {
          "title": "SUV Premium",
          "description": "SUV premium spacieux, tout-terrain et confortable. Équipements haut de gamme.",
          "mileage": "35 000 - 65 000 km",
          "year": "2020 - 2023",
          "price": "20 000€",
          "image": "/reference-assets/modeles/20000/suv-premium.png"
        }
      ],
      "25000": [
        {
          "title": "Citadine Électrique Premium",
          "description": "Citadine électrique haut de gamme, grande autonomie et équipements modernes.",
          "mileage": "15 000 - 40 000 km",
          "year": "2021 - 2024",
          "price": "25 000€",
          "image": "/reference-assets/modeles/25000/citadine-elec.png"
        },
        {
          "title": "Monospace Top Gamme",
          "description": "Monospace top gamme, très spacieux avec équipements premium. Idéal pour grandes familles.",
          "mileage": "20 000 - 50 000 km",
          "year": "2021 - 2024",
          "price": "25 000€",
          "image": "/reference-assets/modeles/25000/mono-top.png"
        },
        {
          "title": "Berline Executive",
          "description": "Berline executive avec finition luxe. Technologie avancée et confort optimal.",
          "mileage": "20 000 - 45 000 km",
          "year": "2022 - 2024",
          "price": "25 000€",
          "image": "/reference-assets/modeles/25000/berline-executive.png"
        },
        {
          "title": "SUV de Luxe",
          "description": "SUV de luxe, très spacieux et puissant. Équipements premium et tout-terrain.",
          "mileage": "25 000 - 55 000 km",
          "year": "2021 - 2024",
          "price": "25 000€",
          "image": "/reference-assets/modeles/25000/suv-luxe.png"
        }
      ],
      "30000": [
        {
          "title": "Compacte Électrique",
          "description": "Compacte électrique récente, bonne autonomie et équipements modernes.",
          "mileage": "10 000 - 35 000 km",
          "year": "2022 - 2024",
          "price": "30 000€",
          "image": "/reference-assets/modeles/30000/compact-elec.png"
        },
        {
          "title": "Monospace Top Luxe",
          "description": "Monospace top luxe, très spacieux avec équipements premium. Confort maximal.",
          "mileage": "15 000 - 40 000 km",
          "year": "2023 - 2024",
          "price": "30 000€",
          "image": "/reference-assets/modeles/30000/mono-top.png"
        },
        {
          "title": "Berline Top Executive",
          "description": "Berline top executive, finition luxe et technologie de pointe. Confort exceptionnel.",
          "mileage": "15 000 - 40 000 km",
          "year": "2023 - 2024",
          "price": "30 000€",
          "image": "/reference-assets/modeles/30000/berline-executive.png"
        },
        {
          "title": "SUV Top Luxe",
          "description": "SUV top luxe, très spacieux et puissant. Équipements premium et performances.",
          "mileage": "20 000 - 45 000 km",
          "year": "2022 - 2024",
          "price": "30 000€",
          "image": "/reference-assets/modeles/30000/suv-luxe.png"
        }
      ],
      "35000": [
        {
          "title": "Électrique Premium",
          "description": "Véhicule électrique premium, grande autonomie et équipements haut de gamme.",
          "mileage": "8 000 - 30 000 km",
          "year": "2023 - 2024",
          "price": "35 000€",
          "image": "/reference-assets/modeles/30000/compact-elec.png"
        },
        {
          "title": "Monospace Ultra Luxe",
          "description": "Monospace ultra luxe, espace maximal et équipements premium. Confort exceptionnel.",
          "mileage": "10 000 - 35 000 km",
          "year": "2023 - 2024",
          "price": "35 000€",
          "image": "/reference-assets/modeles/30000/mono-top.png"
        },
        {
          "title": "Berline Ultra Executive",
          "description": "Berline ultra executive, finition luxe et technologie avancée. Prestige et confort.",
          "mileage": "10 000 - 35 000 km",
          "year": "2023 - 2024",
          "price": "35 000€",
          "image": "/reference-assets/modeles/30000/berline-executive.png"
        },
        {
          "title": "SUV Ultra Luxe",
          "description": "SUV ultra luxe, très spacieux et puissant. Équipements premium et performances exceptionnelles.",
          "mileage": "15 000 - 40 000 km",
          "year": "2023 - 2024",
          "price": "35 000€",
          "image": "/reference-assets/modeles/30000/suv-luxe.png"
        }
      ],
      "40000": [
        {
          "title": "Électrique Top Gamme",
          "description": "Véhicule électrique top gamme, autonomie exceptionnelle et équipements premium.",
          "mileage": "5 000 - 25 000 km",
          "year": "2023 - 2024",
          "price": "40 000€",
          "image": "/reference-assets/modeles/30000/compact-elec.png"
        },
        {
          "title": "Monospace Exclusive",
          "description": "Monospace exclusive, espace maximal et équipements ultra premium. Confort exceptionnel.",
          "mileage": "8 000 - 30 000 km",
          "year": "2023 - 2024",
          "price": "40 000€",
          "image": "/reference-assets/modeles/30000/mono-top.png"
        },
        {
          "title": "Berline Exclusive",
          "description": "Berline exclusive, finition luxe et technologie de pointe. Prestige et élégance.",
          "mileage": "8 000 - 30 000 km",
          "year": "2023 - 2024",
          "price": "40 000€",
          "image": "/reference-assets/modeles/30000/berline-executive.png"
        },
        {
          "title": "SUV Exclusive",
          "description": "SUV exclusive, très spacieux et puissant. Équipements ultra premium et performances.",
          "mileage": "12 000 - 35 000 km",
          "year": "2023 - 2024",
          "price": "40 000€",
          "image": "/reference-assets/modeles/30000/suv-luxe.png"
        }
      ],
      "45000": [],
      "50000": []
    }
  },
  "leasing": {
    "min": 100,
    "max": 1000,
    "step": 100,
    "unit": "€/mois",
    "values": {
      "100": [
        {
          "title": "Citadine LOA économique",
          "description": "Petit budget mensuel pour accéder à une voiture récente.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "100€/mois",
          "image": "/reference-assets/modeles/10000/citadine-recente.png"
        },
        {
          "title": "Compacte LOA",
          "description": "Solution simple pour un usage quotidien sans gros achat initial.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "100€/mois",
          "image": "/reference-assets/modeles/15000/citadine-premium.png"
        },
        {
          "title": "SUV urbain LOA",
          "description": "Format compact avec l’avantage d’un véhicule récent.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "100€/mois",
          "image": "/reference-assets/modeles/10000/suv-compact-recent.png"
        },
        {
          "title": "Hybride compacte LOA",
          "description": "Accès plus facile à une motorisation moderne.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "100€/mois",
          "image": "/reference-assets/modeles/20000/citadine-elec.png"
        }
      ],
      "200": [
        {
          "title": "SUV compact LOA",
          "description": "Mensualité plus confortable pour viser une voiture mieux équipée.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "200€/mois",
          "image": "/reference-assets/modeles/15000/suv-gamme.png"
        },
        {
          "title": "Berline récente LOA",
          "description": "Confort supérieur avec budget mensuel maîtrisé.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "200€/mois",
          "image": "/reference-assets/modeles/15000/berline-premium.png"
        },
        {
          "title": "Break familial LOA",
          "description": "Bon compromis famille / budget sans achat direct.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "200€/mois",
          "image": "/reference-assets/modeles/20000/mono-luxe.png"
        },
        {
          "title": "Hybride LOA",
          "description": "Accès à une solution plus moderne avec mensualité intermédiaire.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "200€/mois",
          "image": "/reference-assets/modeles/25000/citadine-elec.png"
        }
      ],
      "300": [
        {
          "title": "SUV récent LOA +",
          "description": "Mensualité plus haute pour un modèle plus récent et mieux fini.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "300€/mois",
          "image": "/reference-assets/modeles/20000/suv-premium.png"
        },
        {
          "title": "Grande compacte LOA",
          "description": "Plus d’équipement et de choix de finitions.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "300€/mois",
          "image": "/reference-assets/modeles/30000/compact-elec.png"
        },
        {
          "title": "Familiale moderne LOA",
          "description": "Bonne solution pour passer sur une voiture récente sans achat total.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "300€/mois",
          "image": "/reference-assets/modeles/25000/mono-top.png"
        },
        {
          "title": "Hybride bien équipée LOA",
          "description": "Niveau de finition plus élevé avec meilleur lissage budgétaire.",
          "mileage": "Très faible",
          "year": "Récent",
          "price": "300€/mois",
          "image": "/reference-assets/modeles/30000/berline-executive.png"
        }
      ],
      "400": [],
      "500": [],
      "600": [],
      "700": [],
      "800": [],
      "900": [],
      "1000": []
    }
  }
}

export default class extends Controller {
  static targets = ["cards", "range", "modeToggle", "modeKnob", "purchaseLabel", "leasingLabel", "minLabel", "maxLabel", "currentLabel"]

  connect() {
    this.mode = "achat"
    this.updateMode()
  }

  toggle() {
    this.mode = this.mode === "achat" ? "leasing" : "achat"
    this.updateMode()
  }

  showPurchase() {
    this.mode = "achat"
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
    const cards = this.config.values[Number(this.rangeTarget.value)] || []

    if (cards.length === 0) {
      this.cardsTarget.innerHTML = `
        <div class="col-span-full rounded-brand border border-brand-border bg-white p-10 text-center shadow-brand">
          <p class="text-2xl font-bold text-brand-primary">Aucune offre disponible pour ce palier</p>
          <p class="mt-3 text-brand-text-secondary">Ajoute les modèles correspondant à cette tranche.</p>
        </div>
      `
      return
    }

    this.cardsTarget.innerHTML = cards.map((card) => this.cardTemplate(card)).join("")
  }

  cardTemplate(card) {
    return `
      <article class="flex h-full flex-col overflow-hidden rounded-brand border border-brand-border bg-white text-left shadow-brand">
        <div class="flex h-52 w-full shrink-0 items-center justify-center bg-brand-beige p-6">
          <img src="${card.image}" alt="${card.title}" class="h-full w-auto object-contain" />
        </div>
        <div class="flex w-full flex-grow flex-col p-4">
          <h3 class="text-[20px] font-bold leading-tight text-brand-text">${card.title}</h3>
          <p class="fixed-description mt-2 text-[16px] text-brand-text-secondary">${card.description}</p>
          <div class="mt-1 flex flex-row items-center gap-1">
            <div class="flex items-center gap-2">
              <img src="/reference-assets/icons/kilo.svg" alt="Icone roue" class="h-6 w-6 shrink-0">
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Kilométrage</span>
                <span class="text-[11px] text-brand-text-secondary">${card.mileage}</span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <img src="/reference-assets/icons/annee.svg" alt="Icone volant" class="h-6 w-6 shrink-0">
              <div class="flex flex-col">
                <span class="text-[15px] font-bold text-brand-text opacity-90">Année</span>
                <span class="text-[11px] text-brand-text-secondary">${card.year}</span>
              </div>
            </div>
          </div>
          <p class="mt-auto pt-6 text-[24px] text-brand-text">Prix : <span class="font-bold">${card.price}</span></p>
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
