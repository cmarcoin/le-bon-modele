module ApplicationHelper
  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: " ", format: "%n%u", precision: cents.to_i % 100 == 0 ? 0 : 2)
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
end
