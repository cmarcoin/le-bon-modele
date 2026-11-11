import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ce contrôleur est placé sur <body> et installé une seule fois
    // Les écouteurs globaux sont configurés sans utiliser turbo:load
    this.setupGlobalTracking()
  }

  setupGlobalTracking() {
    // Tracking des liens mailto et tel par délégation sur document
    document.addEventListener('click', (e) => {
      const link = e.target.closest('a[href^="mailto:"], a[href^="tel:"]')
      if (!link) return

      const href = link.getAttribute('href')
      const type = href.startsWith('mailto:') ? 'email' : 'telephone'
      if (typeof gtag === 'function') {
        gtag('event', 'clic_contact', { type: type })
      }
    }, { capture: true, once: false })

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

  // Méthode statique pour purchase : appelable depuis n'importe où
  static trackPurchase(transactionId, packName, packId, price, format) {
    // Vérifier si déjà envoyé dans cette session
    const storageKey = `ga4_purchase_${transactionId}`
    if (sessionStorage.getItem(storageKey)) {
      return
    }

    // Convertir phone en telephone
    const normalizedFormat = format === 'phone' ? 'telephone' : format

    if (typeof gtag === 'function') {
      gtag('event', 'purchase', {
        transaction_id: transactionId,
        currency: 'EUR',
        value: parseFloat(price),
        format: normalizedFormat,
        items: [{
          item_id: packId,
          item_name: packName,
          price: parseFloat(price)
        }]
      })
      
      // Marquer comme envoyé
      sessionStorage.setItem(storageKey, 'true')
    }
  }

  // Méthode statique pour generate_lead : appelable depuis n'importe où
  static trackGenerateLead() {
    if (typeof gtag === 'function') {
      gtag('event', 'generate_lead', {
        formulaire: 'contact'
      })
    }
  }
}
