namespace :stripe do
  desc "Synchronise les packs avec les produits et prix Stripe"
  task sync_packs: :environment do
    Pack.order(:name).find_each do |pack|
      StripePackSync.sync!(pack)
      puts "Synchronise: #{pack.slug} -> #{pack.stripe_product_id} / #{pack.stripe_price_id}"
    end
  end
end
