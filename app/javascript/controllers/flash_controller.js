import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dismissAfter: { type: Number, default: 5000 } }

  connect() {
    this.dismissTimer = window.setTimeout(() => this.dismiss(), this.dismissAfterValue)
    this.beforeCacheHandler = () => this.element.remove()
    document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  disconnect() {
    window.clearTimeout(this.dismissTimer)
    document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  dismiss() {
    window.clearTimeout(this.dismissTimer)
    this.element.classList.add("opacity-0")
    window.setTimeout(() => this.element.remove(), 200)
  }
}
