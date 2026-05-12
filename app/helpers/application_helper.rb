module ApplicationHelper
  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: " ", format: "%n%u", precision: cents.to_i % 100 == 0 ? 0 : 2)
  end

  def paris_datetime(time)
    time.in_time_zone("Europe/Paris").strftime("%d/%m/%Y a %H:%M")
  end
end
