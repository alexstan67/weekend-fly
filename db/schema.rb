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

ActiveRecord::Schema[7.0].define(version: 2022_09_25_110801) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string "icao"
    t.string "name"
    t.string "city"
    t.string "country"
    t.string "iata"
    t.float "latitude"
    t.float "longitude"
    t.integer "altitude"
    t.string "dst"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "airport_type"
    t.string "continent"
    t.string "url"
    t.string "local_code"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "alpha2"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "openweather_calls", force: :cascade do |t|
    t.integer "airport_id"
    t.text "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trip_inputs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "dep_airport_icao", null: false
    t.integer "distance", null: false
    t.integer "eet_hour", null: false
    t.integer "average_gs_kts", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "overnights"
    t.boolean "small_airport", default: true
    t.boolean "medium_airport", default: true
    t.boolean "large_airport", default: false
    t.boolean "international_flight", default: false
    t.string "distance_unit", default: "nm", null: false
    t.index ["user_id"], name: "index_trip_inputs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "trip_inputs", "users"
end
