# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160808004258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",               default: "",    null: false
    t.string   "encrypted_password",  default: "",    null: false
    t.datetime "remember_created_at"
    t.boolean  "is_manager",          default: false
    t.integer  "del_flg",             default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree

  create_table "admins", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string   "name"
    t.integer  "num_floors",             null: false
    t.integer  "del_flg",    default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "citizen_cards", force: :cascade do |t|
    t.string   "card_no",    null: false
    t.integer  "ground_id",  null: false
    t.string   "status",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "citizen_cards", ["card_no"], name: "index_citizen_cards_on_card_no", unique: true, using: :btree
  add_index "citizen_cards", ["ground_id"], name: "index_citizen_cards_on_ground_id", using: :btree

  create_table "citizens", force: :cascade do |t|
    t.string   "name"
    t.integer  "ground_id"
    t.string   "government_id"
    t.string   "hometown"
    t.string   "phone"
    t.string   "email"
    t.integer  "gender"
    t.date     "dob"
    t.string   "nationality"
    t.boolean  "is_water_deal", default: false
    t.integer  "del_flg",       default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "citizens", ["ground_id"], name: "index_citizens_on_ground_id", using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "facilities", force: :cascade do |t|
    t.string   "name"
    t.string   "status"
    t.string   "position"
    t.integer  "building_id"
    t.date     "buy_time"
    t.date     "guarantee_time"
    t.string   "guarantee_company"
    t.integer  "del_flg",           default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "facilities", ["building_id"], name: "index_facilities_on_building_id", using: :btree

  create_table "ground_histories", force: :cascade do |t|
    t.integer  "ground_id"
    t.integer  "citizen_id"
    t.date     "come_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ground_histories", ["citizen_id"], name: "index_ground_histories_on_citizen_id", using: :btree
  add_index "ground_histories", ["ground_id"], name: "index_ground_histories_on_ground_id", using: :btree

  create_table "grounds", force: :cascade do |t|
    t.string   "name"
    t.integer  "area_width",        default: 0
    t.integer  "area_length",       default: 0
    t.string   "kind"
    t.string   "status",            default: "Còn trống"
    t.integer  "floor",                                   null: false
    t.integer  "building_id"
    t.string   "images",            default: [],                       array: true
    t.integer  "owner_id"
    t.integer  "num_rooms",         default: 0
    t.integer  "num_citizens",      default: 0
    t.integer  "num_citizen_cards", default: 0
    t.integer  "num_water_deal",    default: 0
    t.integer  "del_flg",           default: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "grounds", ["building_id"], name: "index_grounds_on_building_id", using: :btree
  add_index "grounds", ["name"], name: "index_grounds_on_name", unique: true, using: :btree

  create_table "histories", force: :cascade do |t|
    t.string   "content"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "histories", ["account_id"], name: "index_histories_on_account_id", using: :btree

  create_table "maintains", force: :cascade do |t|
    t.integer  "facility_id"
    t.datetime "fixed_time"
    t.integer  "price",       limit: 8, default: 0
    t.string   "description"
    t.integer  "del_flg",               default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "maintains", ["facility_id"], name: "index_maintains_on_facility_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["account_id"], name: "index_posts_on_account_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "ground_id",                              null: false
    t.integer  "debt",          limit: 8, default: 0
    t.integer  "paid",          limit: 8, default: 0
    t.integer  "fee",           limit: 8, default: 0
    t.integer  "price_service",           default: 8
    t.integer  "price_hygiene",           default: 8
    t.date     "started_time",                           null: false
    t.boolean  "is_current",              default: true
    t.integer  "num_debt",                default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "services", ["ground_id"], name: "index_services_on_ground_id", using: :btree

  create_table "towers", force: :cascade do |t|
    t.string   "name"
    t.string   "area"
    t.string   "address"
    t.string   "phone"
    t.string   "email"
    t.string   "password_digest"
    t.string   "symbol"
    t.string   "fax"
    t.string   "taxcode"
    t.string   "subdomain"
    t.string   "status"
    t.string   "manager_name"
    t.string   "management_board"
    t.string   "bank_no"
    t.string   "receiver_name"
    t.string   "bank_name"
    t.string   "bank_eng"
    t.string   "picture"
    t.string   "activation_digest"
    t.integer  "del_flg",                          default: 1
    t.integer  "payment_date",                     default: 1
    t.integer  "price_service",          limit: 8, default: 0
    t.integer  "price_hygiene",          limit: 8, default: 0
    t.integer  "price_water_lv1",        limit: 8, default: 0
    t.integer  "price_water_lv2",        limit: 8, default: 0
    t.integer  "price_water_lv3",        limit: 8, default: 0
    t.integer  "price_bicycle",          limit: 8, default: 0
    t.integer  "price_electric_bicycle", limit: 8, default: 0
    t.integer  "price_motorbike",        limit: 8, default: 0
    t.integer  "price_car_4_seat",       limit: 8, default: 0
    t.integer  "price_car_7_seat",       limit: 8, default: 0
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "towers", ["email"], name: "index_towers_on_email", unique: true, using: :btree
  add_index "towers", ["subdomain"], name: "index_towers_on_subdomain", unique: true, using: :btree

  create_table "vehicle_cards", force: :cascade do |t|
    t.string   "card_no",                             null: false
    t.string   "license_no"
    t.string   "vehicle_type"
    t.string   "status",          default: "Mới tạo"
    t.integer  "ground_id",                           null: false
    t.integer  "citizen_id",                          null: false
    t.date     "started_time"
    t.integer  "created_fee"
    t.date     "outdate_time"
    t.date     "registered_time"
    t.string   "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "vehicle_cards", ["card_no"], name: "index_vehicle_cards_on_card_no", unique: true, using: :btree
  add_index "vehicle_cards", ["citizen_id"], name: "index_vehicle_cards_on_citizen_id", using: :btree
  add_index "vehicle_cards", ["ground_id"], name: "index_vehicle_cards_on_ground_id", using: :btree

  create_table "vehicle_finances", force: :cascade do |t|
    t.integer  "vehicle_card_id",                       null: false
    t.integer  "ground_id",                             null: false
    t.integer  "debt",            limit: 8, default: 0
    t.integer  "paid",            limit: 8, default: 0
    t.integer  "fee",             limit: 8, default: 0
    t.date     "started_time",                          null: false
    t.boolean  "is_current"
    t.integer  "num_debt",                  default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "vehicle_finances", ["ground_id"], name: "index_vehicle_finances_on_ground_id", using: :btree
  add_index "vehicle_finances", ["vehicle_card_id"], name: "index_vehicle_finances_on_vehicle_card_id", using: :btree

  create_table "waters", force: :cascade do |t|
    t.integer  "ground_id",                                null: false
    t.integer  "water_no",                                 null: false
    t.integer  "water_num",                 default: 0,    null: false
    t.integer  "num_water_deal",            default: 0,    null: false
    t.integer  "debt",            limit: 8, default: 0
    t.integer  "paid",            limit: 8, default: 0
    t.integer  "fee",             limit: 8, default: 0
    t.integer  "price_water_lv1", limit: 8, default: 0
    t.integer  "price_water_lv2", limit: 8, default: 0
    t.integer  "price_water_lv3", limit: 8, default: 0
    t.date     "started_time",                             null: false
    t.boolean  "is_current",                default: true
    t.integer  "num_debt",                  default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "waters", ["ground_id"], name: "index_waters_on_ground_id", using: :btree

  add_foreign_key "citizen_cards", "grounds"
  add_foreign_key "citizens", "grounds"
  add_foreign_key "facilities", "buildings"
  add_foreign_key "ground_histories", "citizens"
  add_foreign_key "ground_histories", "grounds"
  add_foreign_key "grounds", "buildings"
  add_foreign_key "grounds", "citizens", column: "owner_id"
  add_foreign_key "histories", "accounts"
  add_foreign_key "maintains", "facilities"
  add_foreign_key "posts", "accounts"
  add_foreign_key "services", "grounds"
  add_foreign_key "vehicle_cards", "citizens"
  add_foreign_key "vehicle_cards", "grounds"
  add_foreign_key "vehicle_finances", "grounds"
  add_foreign_key "vehicle_finances", "vehicle_cards"
  add_foreign_key "waters", "grounds"
end
