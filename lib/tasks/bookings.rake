namespace :bookings do
  desc "Synchronise les réservations en attente de paiement avec Stripe et envoie les rappels de rendez-vous"
  task maintain_pending_payments: :environment do
    sync_result = PendingPaymentBookingSync.call
    reminder_count = AppointmentReminder.call

    puts "Confirmées : #{sync_result.confirmed_count}"
    puts "Annulées : #{sync_result.canceled_count}"
    puts "Inchangées : #{sync_result.unchanged_count}"
    puts "Rappels de rendez-vous : #{reminder_count}"
  end
end
