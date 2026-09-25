import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { interval: { type: Number, default: 4000 } }

  connect() {
    this.index = 0
    if (this.itemTargets.length < 2) return

    this.timer = setInterval(() => this.rotate(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  rotate() {
    this.index = (this.index + 1) % this.itemTargets.length
    this.itemTargets.forEach((item, index) => {
      item.classList.toggle("hidden", index !== this.index)
    })
  }
}
