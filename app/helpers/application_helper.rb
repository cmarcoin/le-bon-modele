module ApplicationHelper
  def site_copy(key, default = "")
    SiteCopy.fetch(key, default)
  end

  def highlight_le_bon_modele(text, style: :pill)
    safe_text = h(text.to_s)
    highlighted = safe_text.gsub(/Le Bon Modèle/i) do |match|
      case style
      when :bold
        %(<span class="font-bold text-brand-text">#{match}</span>)
      when :plain
        match
      else
        %(<span class="inline-block rounded-xl bg-brand-primary-light px-2 py-0.5 font-black text-brand-primary">#{match}</span>)
      end
    end
    highlighted.html_safe
  end

  def meeting_mode_label(mode)
    {
      "visio" => "En visio",
      "phone" => "Par téléphone"
    }.fetch(mode, mode)
  end

  def french_phone_display(phone)
    digits = phone.to_s.gsub(/\D/, "")
    digits = "0#{digits[2..]}" if digits.start_with?("33") && digits.length == 11
    digits.scan(/.{1,2}/).join(" ")
  end

  def french_phone_tel(phone)
    digits = phone.to_s.gsub(/\D/, "")
    return "+33#{digits[1..]}" if digits.start_with?("0")
    return "+#{digits}" if digits.start_with?("33")

    digits
  end

  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: " ", format: "%n%u", precision: cents.to_i % 100 == 0 ? 0 : 2)
  end

  def booking_cancellation_policy
    "Jusqu’à #{Booking::REFUND_WINDOW_DESCRIPTION} avant le rendez-vous, l’annulation est remboursée intégralement. Dans les #{Booking::REFUND_WINDOW_DESCRIPTION}, ou une fois le créneau passé, l’annulation reste possible, sans remboursement."
  end

  def payment_transaction_status_label(status)
    {
      "pending" => "En attente",
      "paid" => "Payée",
      "failed" => "Échouée",
      "canceled" => "Annulée",
      "refunded" => "Remboursée"
    }.fetch(status, status)
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

  def paris_datetime_full(time)
    paris_time = time.in_time_zone("Europe/Paris")
    day_names = %w[Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi]
    month_names = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre]

    day = day_names[paris_time.wday]
    date = paris_time.day
    month = month_names[paris_time.month - 1]
    year = paris_time.year
    hour = paris_time.hour
    minute = paris_time.min

    time_str = minute.zero? ? "#{hour} h" : "#{hour} h #{minute.to_s.rjust(2, '0')}"
    "#{day} #{date} #{month} #{year} à #{time_str}".gsub(" h", "\u00A0h")
  end

  def paris_date_short(date)
    day_names = %w[dimanche lundi mardi mercredi jeudi vendredi samedi]
    month_names = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre]

    "#{day_names[date.wday]} #{date.day} #{month_names[date.month - 1]} #{date.year}"
  end

  def paris_date_full_no_day(date)
    month_names = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre]
    "#{date.day} #{month_names[date.month - 1]} #{date.year}"
  end

  def paris_time(time)
    time.in_time_zone("Europe/Paris").strftime("%H:%M")
  end

  def paris_day_label(date)
    day_names = %w[Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi]
    month_names = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre]
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
        "Mode : #{meeting_mode_label(booking.meeting_mode).presence || 'Non renseigné'}",
        "Pack : #{booking.pack.name}",
        "Montant : #{euro_price(booking.amount_cents)} TTC"
      ].join("\n"),
      ctz: slot.timezone
    }

    "https://calendar.google.com/calendar/render?#{params.to_query}"
  end
end
