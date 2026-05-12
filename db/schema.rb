# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_12_162600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availability_slots", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "colleague_email", null: false
    t.string "colleague_name", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.bigint "pack_id"
    t.datetime "starts_at", null: false
    t.string "timezone", default: "Europe/Paris", null: false
    t.datetime "updated_at", null: false
    t.index ["pack_id"], name: "index_availability_slots_on_pack_id"
    t.index ["starts_at"], name: "index_availability_slots_on_starts_at"
    t.check_constraint "ends_at > starts_at", name: "availability_slots_end_after_start"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.bigint "availability_slot_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "eur", null: false
    t.string "customer_email", null: false
    t.string "customer_name", null: false
    t.string "customer_phone"
    t.bigint "pack_id", null: false
    t.datetime "paid_at"
    t.string "status", default: "pending_payment", null: false
    t.string "stripe_checkout_session_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["availability_slot_id"], name: "idx_bookings_active_slot", unique: true, where: "((status)::text = ANY ((ARRAY['pending_payment'::character varying, 'paid'::character varying])::text[]))"
    t.index ["availability_slot_id"], name: "index_bookings_on_availability_slot_id"
    t.index ["customer_email"], name: "index_bookings_on_customer_email"
    t.index ["pack_id"], name: "index_bookings_on_pack_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_bookings_on_stripe_checkout_session_id", unique: true
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "packs", force: :cascade do |t|
    t.string "accent_class", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "eur", null: false
    t.text "description", null: false
    t.integer "duration_minutes", default: 45, null: false
    t.string "icon_path", null: false
    t.string "name", null: false
    t.string "objective", null: false
    t.integer "price_cents", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_packs_on_slug", unique: true
    t.check_constraint "duration_minutes > 0", name: "packs_duration_minutes_positive"
    t.check_constraint "price_cents > 0", name: "packs_price_cents_positive"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "eur", null: false
    t.bigint "pack_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_checkout_session_id", null: false
    t.jsonb "stripe_payload", default: {}, null: false
    t.string "stripe_payment_intent_id"
    t.integer "tax_amount_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["booking_id"], name: "index_payment_transactions_on_booking_id"
    t.index ["pack_id"], name: "index_payment_transactions_on_pack_id"
    t.index ["status"], name: "index_payment_transactions_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_payment_transactions_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_payment_transactions_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_payment_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "client", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "availability_slots", "packs"
  add_foreign_key "bookings", "availability_slots"
  add_foreign_key "bookings", "packs"
  add_foreign_key "bookings", "users"
  add_foreign_key "payment_transactions", "bookings"
  add_foreign_key "payment_transactions", "packs"
  add_foreign_key "payment_transactions", "users"
end
