import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button", "label", "openIcon", "closeIcon"]

  connect() {
    this.render(false)
  }

  toggle() {
    const open = this.panelTarget.classList.toggle("hidden") === false
    this.render(open)
  }

  render(open) {
    this.buttonTarget.setAttribute("aria-expanded", open ? "true" : "false")
    if (this.hasLabelTarget) this.labelTarget.textContent = open ? "Réduire" : "En savoir plus"
    if (this.hasOpenIconTarget) this.openIconTarget.classList.toggle("hidden", open)
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.toggle("hidden", !open)
  }
}
