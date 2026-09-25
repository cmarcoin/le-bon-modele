import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  reveal() {
    this.buttonTarget.classList.add("hidden")
    this.panelTarget.classList.remove("hidden")
  }
}
