import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Envoyer l'événement generate_lead
    if (typeof gtag === 'function') {
      gtag('event', 'generate_lead', {
        formulaire: 'contact'
      })
    }
  }
}
