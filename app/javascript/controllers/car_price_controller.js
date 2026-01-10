import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "priceDisplay", "togglePriceDisplay", "carCardsContainer", "toggle", "minLabel", "maxLabel"]
  static values = {
    minPrice: { type: Number, default: 5000 },
    maxPrice: { type: Number, default: 50000 },
    step: { type: Number, default: 5000 }
  }

  connect() {
    this.paymentType = "cash" // "cash" or "lease"
    this.currentPrice = this.minPriceValue
    this.updateSliderRange()
    this.updateSliderBackground()
    this.updateDisplay()
  }

  sliderChanged(event) {
    this.currentPrice = parseInt(event.target.value)
    this.updateSliderBackground()
    this.updateDisplay()
  }

  togglePayment(event) {
    this.paymentType = event.target.checked ? "lease" : "cash"
    this.updateSliderRange()
    this.updateSliderBackground()
    this.updateDisplay()
  }

  updateSliderRange() {
    if (!this.hasSliderTarget) return
    
    const slider = this.sliderTarget
    
    if (this.paymentType === "lease") {
      slider.min = "100"
      slider.max = "1000"
      slider.step = "100"
      slider.value = "100"
      this.currentPrice = 100
      if (this.hasMinLabelTarget) {
        this.minLabelTargets.forEach(target => target.textContent = "100 €/mois")
      }
      if (this.hasMaxLabelTarget) {
        this.maxLabelTargets.forEach(target => target.textContent = "1 000 €/mois")
      }
    } else {
      slider.min = "5000"
      slider.max = "50000"
      slider.step = "5000"
      slider.value = "5000"
      this.currentPrice = 5000
      if (this.hasMinLabelTarget) {
        this.minLabelTargets.forEach(target => target.textContent = "5 000 €")
      }
      if (this.hasMaxLabelTarget) {
        this.maxLabelTargets.forEach(target => target.textContent = "50 000 €")
      }
    }
  }

  updateSliderBackground() {
    if (!this.hasSliderTarget) return
    
    const slider = this.sliderTarget
    const min = parseInt(slider.min)
    const max = parseInt(slider.max)
    const value = this.currentPrice
    const percentage = ((value - min) / (max - min)) * 100
    slider.style.background = `linear-gradient(to right, #1A3B8F 0%, #1A3B8F ${percentage}%, #E0F0FF ${percentage}%, #E0F0FF 100%)`
  }

  updateDisplay() {
    // Update main price display
    if (this.paymentType === "lease") {
      this.priceDisplayTargets.forEach(target => {
        target.textContent = `${this.currentPrice}€/mois`
      })
      if (this.hasTogglePriceDisplayTarget) {
        this.togglePriceDisplayTarget.textContent = `${this.currentPrice}€/mois`
      }
    } else {
      this.priceDisplayTargets.forEach(target => {
        target.textContent = this.formatPrice(this.currentPrice)
      })
      if (this.hasTogglePriceDisplayTarget) {
        this.togglePriceDisplayTarget.textContent = this.formatPrice(this.currentPrice)
      }
    }

    // Update car cards - get all cards within the container
    const cars = this.getCarsForPrice(this.currentPrice)
    
    if (this.hasCarCardsContainerTarget) {
      const cards = this.carCardsContainerTarget.querySelectorAll('[data-car-card]')
      
      cards.forEach((card, index) => {
        if (cars[index]) {
          this.updateCarCard(card, cars[index])
        }
      })
    }
  }

  formatPrice(price) {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(price)
  }

  getCarsForPrice(price) {
    // Get cars data from the script tag
    const dataScript = document.getElementById('car-price-data')
    if (!dataScript) return []
    
    let carsData
    try {
      carsData = JSON.parse(dataScript.textContent)
    } catch (e) {
      console.error('Error parsing car data:', e)
      return []
    }
    
    const paymentData = carsData[this.paymentType]
    if (!paymentData) return []
    
    const priceKey = price.toString()
    return paymentData[priceKey] || []
  }

  updateCarCard(card, carData) {
    const title = card.querySelector('[data-car-title]')
    const description = card.querySelector('[data-car-description]')
    const price = card.querySelector('[data-car-price]')
    const image = card.querySelector('[data-car-image]')
    const mileage = card.querySelector('[data-car-mileage]')
    const year = card.querySelector('[data-car-year]')

    if (title) title.textContent = carData.title
    if (description) description.textContent = carData.description
    if (mileage) mileage.textContent = carData.mileage
    if (year) year.textContent = carData.year

    // Update price based on payment type
    if (price) {
      if (this.paymentType === "lease") {
        price.textContent = `${this.currentPrice}€/mois`
        price.setAttribute('data-payment-type', 'lease')
      } else {
        price.textContent = this.formatPrice(this.currentPrice)
        price.setAttribute('data-payment-type', 'cash')
      }
    }

    // Update image placeholder
    if (image) {
      image.setAttribute('data-car-type', carData.type)
      image.setAttribute('alt', carData.title)
    }
  }
}
