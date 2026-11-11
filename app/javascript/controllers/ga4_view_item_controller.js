import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    packName: String,
    packId: String,
    price: Number
  }

  connect() {
    // Envoyer l'événement view_item une seule fois au chargement
    this.trackViewItem()
  }

  trackViewItem() {
    if (typeof gtag !== 'function') return

    gtag('event', 'view_item', {
      currency: 'EUR',
      value: this.priceValue,
      items: [{
        item_id: this.packIdValue,
        item_name: this.packNameValue,
        price: this.priceValue
      }]
    })
  }
}
