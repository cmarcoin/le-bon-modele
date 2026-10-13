import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.itemTargets.forEach((item) => this.closeItem(item))
  }

  toggle(event) {
    const item = event.currentTarget.closest(".faq-item")
    const isOpen = item.dataset.open === "true"

    this.itemTargets.forEach((otherItem) => this.closeItem(otherItem))

    if (!isOpen) this.openItem(item)
  }

  openItem(item) {
    const button = item.querySelector(".faq-question")
    const answer = item.querySelector(".faq-answer")

    item.dataset.open = "true"
    button?.setAttribute("aria-expanded", "true")
    if (answer) answer.style.maxHeight = `${answer.scrollHeight}px`
  }

  closeItem(item) {
    const button = item.querySelector(".faq-question")
    const answer = item.querySelector(".faq-answer")

    item.dataset.open = "false"
    button?.setAttribute("aria-expanded", "false")
    if (answer) answer.style.maxHeight = "0px"
  }
}
