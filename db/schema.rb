# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_12_215550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "access_keys", force: :cascade do |t|
    t.string "access_key_id", null: false
    t.string "secret_access_key", null: false
    t.integer "status", default: 1
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_key_id"], name: "index_access_keys_on_access_key_id", unique: true
    t.index ["product_id"], name: "index_access_keys_on_product_id"
    t.index ["secret_access_key"], name: "index_access_keys_on_secret_access_key", unique: true
  end

  create_table "claim_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "product_id"
    t.string "access_key_id"
    t.string "request_uuid"
    t.string "pk160"
    t.string "signature"
    t.integer "request_type"
    t.string "request_timestamp"
    t.decimal "capacity"
    t.integer "status", default: 0
    t.string "tx_hash"
    t.integer "tx_status", default: 0
    t.integer "created_at_unixtimestamp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at_unixtimestamp"], name: "index_claim_events_on_created_at_unixtimestamp"
    t.index ["id", "tx_hash", "tx_status"], name: "index_claim_events_on_id_and_tx_hash_and_tx_status"
    t.index ["product_id"], name: "index_claim_events_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "access_key_id"
    t.string "secret_access_key"
    t.jsonb "quota_config"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_key_id", "secret_access_key"], name: "index_products_on_access_key_id_and_secret_access_key", unique: true
  end

end
