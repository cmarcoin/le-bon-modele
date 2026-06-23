class AddBillingAddressToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :billing_line1, :string
    add_column :bookings, :billing_postal_code, :string
    add_column :bookings, :billing_city, :string
    add_column :bookings, :billing_country, :string, default: "FR", null: false
  end
end
