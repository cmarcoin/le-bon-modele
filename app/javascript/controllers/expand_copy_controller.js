import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    const open = this.panelTarget.classList.toggle("hidden") === false
    this.buttonTarget.textContent = open ? "Réduire" : "En savoir plus"
  }
}
