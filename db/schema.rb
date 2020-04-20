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

ActiveRecord::Schema.define(version: 2020_04_13_104748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "aasm_state"
    t.integer "max_players", limit: 2, default: 2, null: false
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "fight_results", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "location", null: false
    t.string "fight_data", null: false
    t.string "fight_log", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "movements_result_id"
    t.index ["campaign_id"], name: "index_fight_results_on_campaign_id"
    t.index ["movements_result_id"], name: "index_fight_results_on_movements_result_id", unique: true
  end

  create_table "gangs", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "player_id", null: false
    t.string "icon", null: false
    t.float "points", default: 0.0, null: false
    t.integer "number", limit: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "location", null: false
    t.string "faction", null: false
    t.string "name"
    t.integer "movement_order"
    t.string "movements"
    t.string "movements_backup"
    t.index ["campaign_id"], name: "index_gangs_on_campaign_id"
    t.index ["player_id"], name: "index_gangs_on_player_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "data", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_logs_on_campaign_id"
  end

  create_table "movements_results", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "player_id", null: false
    t.bigint "gang_id", null: false
    t.string "from", null: false
    t.string "to", null: false
    t.string "interception"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_movements_results_on_campaign_id"
    t.index ["gang_id"], name: "index_movements_results_on_gang_id"
    t.index ["player_id"], name: "index_movements_results_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "user_id", null: false
    t.integer "pp", default: 0, null: false
    t.integer "god_favor"
    t.integer "god_favored"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "controls_points"
    t.integer "initiative"
    t.string "faction"
    t.boolean "movements_orders_finalized", default: false, null: false
    t.integer "initiative_bet"
    t.index ["campaign_id"], name: "index_players_on_campaign_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "unit_old_libe_strings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "libe", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_unit_old_libe_strings_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "gang_id", null: false
    t.string "libe", null: false
    t.integer "amount", limit: 2, null: false
    t.float "points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "weapon", null: false
    t.string "name"
    t.index ["gang_id"], name: "index_units_on_gang_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "name", null: false
    t.string "icon_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "campaigns", "users"
  add_foreign_key "fight_results", "campaigns"
  add_foreign_key "gangs", "campaigns"
  add_foreign_key "gangs", "players"
  add_foreign_key "logs", "campaigns"
  add_foreign_key "movements_results", "campaigns"
  add_foreign_key "movements_results", "gangs"
  add_foreign_key "movements_results", "players"
  add_foreign_key "players", "campaigns"
  add_foreign_key "players", "users"
  add_foreign_key "unit_old_libe_strings", "users"
  add_foreign_key "units", "gangs"
end
