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

ActiveRecord::Schema.define(version: 2020_03_09_213025) do

  create_table "campaigns", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "gangs", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "player_id", null: false
    t.string "icon", null: false
    t.float "points", default: 0.0, null: false
    t.integer "number", limit: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "location", null: false
    t.string "faction", null: false
    t.index ["campaign_id"], name: "index_gangs_on_campaign_id"
    t.index ["player_id"], name: "index_gangs_on_player_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "data", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_logs_on_campaign_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "user_id", null: false
    t.integer "pp", default: 0, null: false
    t.integer "god_favor"
    t.integer "god_favored"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_players_on_campaign_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "unit_old_libe_strings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "libe", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_unit_old_libe_strings_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.integer "gang_id", null: false
    t.string "libe", null: false
    t.integer "amount", limit: 1, null: false
    t.float "points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
  add_foreign_key "gangs", "campaigns"
  add_foreign_key "gangs", "players"
  add_foreign_key "logs", "campaigns"
  add_foreign_key "players", "campaigns"
  add_foreign_key "players", "users"
  add_foreign_key "unit_old_libe_strings", "users"
  add_foreign_key "units", "gangs"
end
