namespace :bookings do
  desc "Synchronise les réservations en attente de paiement avec Stripe et envoie les relances"
  task maintain_pending_payments: :environment do
    sync_result = PendingPaymentBookingSync.call
    reminder_count = PendingPaymentBookingReminder.call

    puts "Confirmées : #{sync_result.confirmed_count}"
    puts "Annulées : #{sync_result.canceled_count}"
    puts "Inchangées : #{sync_result.unchanged_count}"
    puts "Relances envoyées : #{reminder_count}"
  end
end
