import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ce contrôleur est utilisé pour suivre les événements GA4
    // Exposer les méthodes statiques globalement
    window.Ga4TrackingController = this.constructor
    
    // Configurer les écouteurs globaux si on est sur turbo:load
    document.addEventListener('turbo:load', () => {
      this.setupGlobalTracking()
    }, { once: false })
    
    this.setupGlobalTracking()
  }

  setupGlobalTracking() {
    // Tracking des liens mailto et tel
    document.querySelectorAll('a[href^="mailto:"], a[href^="tel:"]').forEach(link => {
      if (!link.dataset.ga4TrackedLink) {
        link.dataset.ga4TrackedLink = 'true'
        link.addEventListener('click', (e) => {
          const href = e.currentTarget.getAttribute('href')
          const type = href.startsWith('mailto:') ? 'email' : 'telephone'
          if (typeof gtag === 'function') {
            gtag('event', 'clic_contact', { type: type })
          }
        })
      }
    })

    // Tracking de l'ouverture du chat Crisp
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

  // Événement view_item : consultation d'une offre
  trackViewItem(event) {
    const packName = event.params.packName
    const packId = event.params.packId
    const price = parseFloat(event.params.price)

    if (typeof gtag === 'function') {
      gtag('event', 'view_item', {
        currency: 'EUR',
        value: price,
        items: [{
          item_id: packId,
          item_name: packName,
          price: price
        }]
      })
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

  // Événement purchase : paiement confirmé (appelé directement depuis la page)
  static trackPurchase(transactionId, packName, packId, price, format) {
    // Vérifier si déjà envoyé dans cette session
    const storageKey = `ga4_purchase_${transactionId}`
    if (sessionStorage.getItem(storageKey)) {
      return
    }

    if (typeof gtag === 'function') {
      gtag('event', 'purchase', {
        transaction_id: transactionId,
        currency: 'EUR',
        value: parseFloat(price),
        format: format,
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

  // Événement generate_lead : formulaire de contact envoyé
  static trackGenerateLead() {
    if (typeof gtag === 'function') {
      gtag('event', 'generate_lead', {
        formulaire: 'contact'
      })
    }
  }
}
