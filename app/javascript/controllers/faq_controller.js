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

    if (!isOpen) {
      this.openItem(item)
    }
  }

  openItem(item) {
    const button = item.querySelector(".faq-question")
    const answer = item.querySelector(".faq-answer")
    const icon = item.querySelector(".faq-icon")
    const label = item.querySelector(".faq-label")

    item.dataset.open = "true"
    item.classList.remove("bg-brand-primary-light")
    item.classList.add("bg-brand-primary", "shadow-brand")
    button?.setAttribute("aria-expanded", "true")

    if (answer) {
      answer.style.maxHeight = `${answer.scrollHeight}px`
    }

    icon?.classList.remove("text-brand-primary")
    icon?.classList.add("text-white")
    if (icon) icon.textContent = "–"

    label?.classList.remove("text-brand-primary")
    label?.classList.add("text-white")
  }

  closeItem(item) {
    const button = item.querySelector(".faq-question")
    const answer = item.querySelector(".faq-answer")
    const icon = item.querySelector(".faq-icon")
    const label = item.querySelector(".faq-label")

    item.dataset.open = "false"
    item.classList.remove("bg-brand-primary", "shadow-brand")
    item.classList.add("bg-brand-primary-light")
    button?.setAttribute("aria-expanded", "false")

    if (answer) {
      answer.style.maxHeight = "0px"
    }

    icon?.classList.remove("text-white")
    icon?.classList.add("text-brand-primary")
    if (icon) icon.textContent = "+"

    label?.classList.remove("text-white")
    label?.classList.add("text-brand-primary")
  }
}
