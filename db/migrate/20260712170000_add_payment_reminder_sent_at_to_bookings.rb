class AddPaymentReminderSentAtToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :payment_reminder_sent_at, :datetime
    add_index :bookings, :payment_reminder_sent_at
  end
end
