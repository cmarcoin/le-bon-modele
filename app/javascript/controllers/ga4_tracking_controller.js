import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ce contrôleur est placé sur <body> et se reconnecte à chaque navigation Turbo
    // Les écouteurs globaux sont installés une seule fois via un flag global
    this.setupGlobalTracking()
  }

  setupGlobalTracking() {
    // Installer l'écouteur de clic une seule fois pour éviter les doublons
    if (!window.ga4ClickTrackingInstalled) {
      window.ga4ClickTrackingInstalled = true
      document.addEventListener('click', (e) => {
      const link = e.target.closest('a[href^="mailto:"], a[href^="tel:"]')
      if (!link) return

      const href = link.getAttribute('href')
      const type = href.startsWith('mailto:') ? 'email' : 'telephone'
      if (typeof gtag === 'function') {
        gtag('event', 'clic_contact', { type: type })
      }
    }, { capture: true, once: false })
    }

    // Tracking de l'ouverture du chat Crisp (une seule fois)
    if (typeof window.$crisp !== 'undefined' && !window.crispChatTracked) {
      window.crispChatTracked = true
      window.$crisp.push(['on', 'chat:opened', () => {
        if (typeof gtag === 'function') {
          gtag('event', 'chat_ouvert', {
            page: location.pathname
          })
        }
      }])
    }
  }

  // Événement select_item : clic sur un bouton de réservation
  trackSelectItem(event) {
    const packName = event.params.packName
    const packId = event.params.packId
    const location = event.params.location

    if (typeof gtag === 'function') {
      gtag('event', 'select_item', {
        items: [{
          item_id: packId,
          item_name: packName
        }],
        emplacement: location
      })
    }
  }
}
