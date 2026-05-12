class CreateSalesFunnel < ActiveRecord::Migration[8.1]
  def change
    create_table :packs do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :objective, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "eur"
      t.integer :duration_minutes, null: false, default: 45
      t.string :icon_path, null: false
      t.string :accent_class, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :packs, :slug, unique: true
    add_check_constraint :packs, "price_cents > 0", name: "packs_price_cents_positive"
    add_check_constraint :packs, "duration_minutes > 0", name: "packs_duration_minutes_positive"

    create_table :availability_slots do |t|
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :timezone, null: false, default: "Europe/Paris"
      t.string :colleague_name, null: false
      t.string :colleague_email, null: false
      t.references :pack, null: true, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :availability_slots, :starts_at
    add_check_constraint :availability_slots, "ends_at > starts_at", name: "availability_slots_end_after_start"

    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pack, null: false, foreign_key: true
      t.references :availability_slot, null: false, foreign_key: true
      t.string :status, null: false, default: "pending_payment"
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.string :customer_phone
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "eur"
      t.string :stripe_checkout_session_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :bookings, :customer_email
    add_index :bookings, :status
    add_index :bookings, :stripe_checkout_session_id, unique: true
    add_index :bookings, :availability_slot_id, unique: true, where: "status IN ('pending_payment', 'paid')", name: "idx_bookings_active_slot"

    create_table :payment_transactions do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :pack, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :amount_cents, null: false
      t.integer :tax_amount_cents, null: false, default: 0
      t.string :currency, null: false, default: "eur"
      t.string :stripe_checkout_session_id, null: false
      t.string :stripe_payment_intent_id
      t.jsonb :stripe_payload, null: false, default: {}

      t.timestamps
    end

    add_index :payment_transactions, :status
    add_index :payment_transactions, :stripe_checkout_session_id, unique: true
    add_index :payment_transactions, :stripe_payment_intent_id
  end
end
