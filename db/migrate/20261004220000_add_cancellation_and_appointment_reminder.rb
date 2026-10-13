class AddCancellationAndAppointmentReminder < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :canceled_at, :datetime
    add_column :bookings, :appointment_reminder_sent_at, :datetime
    add_index :bookings, :appointment_reminder_sent_at

    add_column :payment_transactions, :refunded_at, :datetime
    add_column :payment_transactions, :stripe_refund_id, :string
    add_index :payment_transactions, :stripe_refund_id, unique: true
  end
end
