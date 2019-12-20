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

ActiveRecord::Schema.define(version: 2019_12_20_034117) do

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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"campaign\", \"player\"", name: "index_gangs_on_campaign_and_player", unique: true
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
end
