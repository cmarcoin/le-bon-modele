import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "openIcon", "closeIcon"]
  static classes = ["scrolled"]

  connect() {
    this.updateScrollState = this.updateScrollState.bind(this)
    window.addEventListener("scroll", this.updateScrollState, { passive: true })
    this.updateScrollState()
  }

  disconnect() {
    window.removeEventListener("scroll", this.updateScrollState)
    document.body.style.overflow = ""
  }

  toggle() {
    if (this.overlayTarget.classList.contains("active")) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.overlayTarget.classList.add("active")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.overlayTarget.classList.remove("active")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  updateScrollState() {
    this.element.classList.toggle(this.scrolledClass, window.scrollY > 30)
  }
}
