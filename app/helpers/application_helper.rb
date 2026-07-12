module ApplicationHelper
  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: " ", format: "%n%u", precision: cents.to_i % 100 == 0 ? 0 : 2)
  end

  def booking_status_label(status)
    {
      "pending_payment" => "En attente de paiement",
      "paid" => "Payée",
      "canceled" => "Annulée"
    }.fetch(status, status)
  end

  def booking_status_class(status)
    {
      "pending_payment" => "text-brand-coral",
      "paid" => "text-brand-primary",
      "canceled" => "text-brand-text-secondary"
    }.fetch(status, "text-brand-text")
  end

  def paris_datetime(time)
    time.in_time_zone("Europe/Paris").strftime("%d/%m/%Y a %H:%M")
  end

  def paris_time(time)
    time.in_time_zone("Europe/Paris").strftime("%H:%M")
  end

  def paris_day_label(date)
    day_names = %w[Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi]
    month_names = %w[janvier fevrier mars avril mai juin juillet aout septembre octobre novembre decembre]
    "#{day_names[date.wday]} #{date.day} #{month_names[date.month - 1]}"
  end

  def paris_short_date(date)
    date.strftime("%d/%m")
  end

  def google_calendar_url_for(booking)
    slot = booking.availability_slot
    zone = ActiveSupport::TimeZone[slot.timezone] || Time.zone

    start_time = slot.starts_at.in_time_zone(zone)
    end_time = slot.ends_at.in_time_zone(zone)

    params = {
      action: "TEMPLATE",
      text: "#{booking.pack.name} — #{booking.customer_name}",
      dates: "#{start_time.strftime('%Y%m%dT%H%M%S')}/#{end_time.strftime('%Y%m%dT%H%M%S')}",
      details: [
        "Client : #{booking.customer_name}",
        "Email : #{booking.customer_email}",
        "Téléphone : #{booking.customer_phone.presence || 'Non renseigné'}",
        "Pack : #{booking.pack.name}",
        "Montant : #{euro_price(booking.amount_cents)} TTC"
      ].join("\n"),
      ctz: slot.timezone
    }

    "https://calendar.google.com/calendar/render?#{params.to_query}"
  end
end
