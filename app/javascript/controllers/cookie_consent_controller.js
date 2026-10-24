import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Enregistrer l'instance globalement pour le bouton du footer
    window.cookieConsentController = this
    
    // Vérifier si un choix a déjà été fait
    const consent = this.getConsent()
    
    if (consent === null) {
      // Pas de choix enregistré, afficher le bandeau
      this.element.classList.remove("hidden")
    } else {
      // Un choix existe, appliquer le consentement
      this.applyConsent(consent)
    }
  }

  disconnect() {
    // Nettoyer la référence globale
    delete window.cookieConsentController
  }

  accept() {
    this.saveConsent(true)
    this.applyConsent(true)
    this.hideBanner()
  }

  refuse() {
    this.saveConsent(false)
    this.applyConsent(false)
    this.hideBanner()
  }

  saveConsent(accepted) {
    const consent = {
      analytics: accepted,
      timestamp: Date.now()
    }
    localStorage.setItem("cookie_consent", JSON.stringify(consent))
  }

  getConsent() {
    const stored = localStorage.getItem("cookie_consent")
    if (!stored) return null

    const consent = JSON.parse(stored)
    const sixMonthsMs = 6 * 30 * 24 * 60 * 60 * 1000
    
    // Vérifier si le consentement a expiré (6 mois)
    if (Date.now() - consent.timestamp > sixMonthsMs) {
      localStorage.removeItem("cookie_consent")
      return null
    }

    return consent.analytics
  }

  applyConsent(accepted) {
    if (typeof gtag !== 'function') return

    if (accepted) {
      // Mettre à jour le consentement : accordé
      gtag('consent', 'update', {
        'analytics_storage': 'granted',
        'ad_storage': 'denied',
        'ad_user_data': 'denied',
        'ad_personalization': 'denied'
      })
    } else {
      // Consentement refusé, garder denied
      gtag('consent', 'update', {
        'analytics_storage': 'denied',
        'ad_storage': 'denied',
        'ad_user_data': 'denied',
        'ad_personalization': 'denied'
      })
    }
  }

  hideBanner() {
    this.element.classList.add("hidden")
  }

  // Méthode appelée depuis le lien "Gérer les cookies" dans le footer
  show() {
    this.element.classList.remove("hidden")
  }
}
