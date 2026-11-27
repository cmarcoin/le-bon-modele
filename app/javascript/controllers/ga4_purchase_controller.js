import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    transactionId: String,
    packName: String,
    packId: String,
    price: Number,
    format: String
  }

  connect() {
    // Vérifier si déjà envoyé dans cette session
    const storageKey = `ga4_purchase_${this.transactionIdValue}`
    if (sessionStorage.getItem(storageKey)) {
      return
    }

    // Convertir phone en telephone
    const normalizedFormat = this.formatValue === 'phone' ? 'telephone' : this.formatValue

    if (typeof gtag === 'function') {
      gtag('event', 'purchase', {
        transaction_id: this.transactionIdValue,
        currency: 'EUR',
        value: parseFloat(this.priceValue),
        format: normalizedFormat,
        items: [{
          item_id: this.packIdValue,
          item_name: this.packNameValue,
          price: parseFloat(this.priceValue)
        }]
      })
      
      // Marquer comme envoyé
      sessionStorage.setItem(storageKey, 'true')
    }
  }
}
