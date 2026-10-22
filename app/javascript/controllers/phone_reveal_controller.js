import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  reveal() {
    this.buttonTarget.hidden = true
    this.panelTarget.hidden = false
    this.panelTarget.classList.remove("hidden")
  }
}
