import { Controller } from "@hotwired/stimulus"

const MONTHS = [
  "janvier", "fevrier", "mars", "avril", "mai", "juin",
  "juillet", "aout", "septembre", "octobre", "novembre", "decembre"
]

export default class extends Controller {
  static targets = [
    "calendar",
    "monthLabel",
    "timePanel",
    "timeSlot",
    "summary",
    "selectedDayLabel",
    "timesSection"
  ]

  static values = {
    availableDates: Array,
    today: String,
    initialMonth: String,
    initialDate: String
  }

  connect() {
    this.availableDateSet = new Set(this.availableDatesValue)
    const sortedDates = [ ...this.availableDateSet ].sort()

    if (this.initialDateValue && this.availableDateSet.has(this.initialDateValue)) {
      this.selectedDate = this.initialDateValue
      this.currentMonth = this.monthKeyFromDate(this.initialDateValue)
    } else if (sortedDates.length > 0) {
      this.selectedDate = sortedDates[0]
      this.currentMonth = this.monthKeyFromDate(sortedDates[0])
    } else if (this.initialMonthValue) {
      this.currentMonth = this.initialMonthValue
      this.selectedDate = null
    } else {
      this.currentMonth = this.monthKeyFromDate(this.todayValue)
      this.selectedDate = null
    }

    this.renderCalendar()
    this.showTimesForSelectedDate()
  }

  previousMonth() {
    this.currentMonth = this.shiftMonth(this.currentMonth, -1)
    this.renderCalendar()
  }

  nextMonth() {
    this.currentMonth = this.shiftMonth(this.currentMonth, 1)
    this.renderCalendar()
  }

  selectDate(event) {
    const { date } = event.currentTarget.dataset
    if (!this.availableDateSet.has(date) || date < this.todayValue) return

    this.selectedDate = date
    this.renderCalendar()
    this.showTimesForSelectedDate()
  }

  selectTime(event) {
    this.highlightSelectedTime(event.target)
    this.updateSummary(event.target)
  }

  renderCalendar() {
    const [ year, month ] = this.currentMonth.split("-").map(Number)
    const firstDay = new Date(year, month - 1, 1)
    const daysInMonth = new Date(year, month, 0).getDate()
    const startOffset = (firstDay.getDay() + 6) % 7

    this.monthLabelTarget.textContent = `${MONTHS[month - 1]} ${year}`

    let html = ""
    for (let index = 0; index < startOffset; index += 1) {
      html += "<div></div>"
    }

    for (let day = 1; day <= daysInMonth; day += 1) {
      const dateKey = `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`
      const available = this.availableDateSet.has(dateKey)
      const selected = dateKey === this.selectedDate
      const isPast = dateKey < this.todayValue
      const isToday = dateKey === this.todayValue

      if (available && !isPast) {
        html += `
          <button
            type="button"
            data-date="${dateKey}"
            data-action="booking-scheduler#selectDate"
            class="mx-auto flex h-11 w-11 items-center justify-center rounded-full text-sm font-bold transition ${this.dayButtonClasses(selected, isToday)}"
            aria-label="${dateKey}"
            aria-pressed="${selected}"
          >
            ${day}
          </button>
        `
      } else {
        html += `
          <span class="mx-auto flex h-11 w-11 items-center justify-center text-sm ${isPast ? "text-brand-text-secondary/40" : "text-brand-text-secondary/25"}">
            ${day}
          </span>
        `
      }
    }

    this.calendarTarget.innerHTML = html
  }

  dayButtonClasses(selected, isToday) {
    if (selected) {
      return "bg-brand-primary text-white"
    }

    if (isToday) {
      return "border-2 border-brand-primary text-brand-primary hover:bg-brand-beige"
    }

    return "text-brand-primary hover:bg-brand-beige"
  }

  showTimesForSelectedDate() {
    if (this.hasSelectedDayLabelTarget) {
      this.selectedDayLabelTarget.textContent = this.selectedDate
        ? this.formatSelectedDayLabel(this.selectedDate)
        : ""
    }

    if (this.hasTimesSectionTarget) {
      this.timesSectionTarget.hidden = !this.selectedDate
    }

    this.timePanelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.date !== this.selectedDate
    })

    if (!this.selectedDate) {
      if (this.hasSummaryTarget) this.summaryTarget.textContent = ""
      return
    }

    const selectedPanel = this.timePanelTargets.find((panel) => panel.dataset.date === this.selectedDate)
    const firstRadio = selectedPanel?.querySelector("input[type=radio]")
    if (firstRadio) {
      firstRadio.checked = true
      this.highlightSelectedTime(firstRadio)
      this.updateSummary(firstRadio)
    }
  }

  highlightSelectedTime(selectedRadio) {
    this.timeSlotTargets.forEach((slot) => {
      const radio = slot.querySelector("input[type=radio]")
      const selected = radio === selectedRadio
      slot.classList.toggle("border-brand-primary", selected)
      slot.classList.toggle("bg-brand-primary", selected)
      slot.classList.toggle("text-white", selected)
      slot.classList.toggle("border-[#E7E2DC]", !selected)
      slot.classList.toggle("bg-white", !selected)
      slot.classList.toggle("text-brand-text", !selected)
    })
  }

  updateSummary(radio) {
    const label = radio.closest("label")
    if (!label || !this.hasSummaryTarget) return

    const time = label.dataset.time
    const date = label.dataset.dateLabel
    this.summaryTarget.textContent = `${date} a ${time}`
  }

  formatSelectedDayLabel(dateKey) {
    const [ year, month, day ] = dateKey.split("-").map(Number)
    const date = new Date(year, month - 1, day)
    const dayNames = [ "dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi" ]
    const monthName = MONTHS[month - 1]
    const dayName = dayNames[date.getDay()]
    return `${dayName.charAt(0).toUpperCase() + dayName.slice(1)} ${day} ${monthName}`
  }

  monthKeyFromDate(dateKey) {
    return dateKey.slice(0, 7)
  }

  shiftMonth(monthKey, delta) {
    const [ year, month ] = monthKey.split("-").map(Number)
    const date = new Date(year, month - 1 + delta, 1)
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`
  }
}
