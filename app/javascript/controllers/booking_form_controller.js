import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.refresh()
  }

  refresh() {
    if (!this.hasSubmitTarget) return

    const slotSelected = Boolean(this.element.querySelector("input[name='booking[availability_slot_id]']:checked"))
    const name = this.element.querySelector("#booking_customer_name")?.value?.trim()
    const email = this.element.querySelector("#booking_customer_email")?.value?.trim()
    const meetingMode = Boolean(this.element.querySelector("input[name='booking[meeting_mode]']:checked"))
    const hasSlots = Boolean(this.element.querySelector("input[name='booking[availability_slot_id]']"))

    this.submitTarget.disabled = !(hasSlots && slotSelected && name && email && meetingMode)
  }
}
