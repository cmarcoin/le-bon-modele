import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.refresh()
    
    // Ajouter l'événement begin_checkout au submit du formulaire
    this.element.addEventListener('submit', (e) => this.trackBeginCheckout(e))
  }

  refresh() {
    if (!this.hasSubmitTarget) return

    const slotSelected = Boolean(this.element.querySelector("input[name='booking[availability_slot_id]']:checked"))
    const name = this.element.querySelector("#booking_customer_name")?.value?.trim()
    const email = this.element.querySelector("#booking_customer_email")?.value?.trim()
    const meetingMode = Boolean(this.element.querySelector("input[name='booking[meeting_mode]']:checked"))
    const hasSlots = Boolean(this.element.querySelector("input[name='booking[availability_slot_id]']"))

    this.submitTarget.disabled = !(hasSlots && slotSelected && name && email && meetingMode)
  }

  trackBeginCheckout(event) {
    if (typeof gtag !== 'function') return

    // Récupérer les informations du pack et du format
    const packName = this.element.dataset.packName
    const packId = this.element.dataset.packId
    const price = parseFloat(this.element.dataset.packPrice)
    const meetingModeInput = this.element.querySelector("input[name='booking[meeting_mode]']:checked")
    const format = meetingModeInput ? meetingModeInput.value : ''

    let eventSent = false

    // Envoyer l'événement avec callback
    gtag('event', 'begin_checkout', {
      currency: 'EUR',
      value: price,
      format: format,
      items: [{
        item_id: packId,
        item_name: packName,
        price: price
      }],
      event_callback: function() {
        eventSent = true
      }
    })

    // Délai de secours de 1 seconde max
    setTimeout(function() {
      if (!eventSent) {
        console.log('GA4 begin_checkout event timeout, continuing submission')
      }
    }, 1000)
  }
}
