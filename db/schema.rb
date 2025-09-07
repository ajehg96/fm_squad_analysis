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

ActiveRecord::Schema[8.0].define(version: 2025_09_07_093022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "player_snapshots", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.date "snapshot_date"
    t.integer "att_cor"
    t.integer "att_cro"
    t.integer "att_dri"
    t.integer "att_fin"
    t.integer "att_fir"
    t.integer "att_fre"
    t.integer "att_hea"
    t.integer "att_lon"
    t.integer "att_lth"
    t.integer "att_mar"
    t.integer "att_pas"
    t.integer "att_pen"
    t.integer "att_tck"
    t.integer "att_tec"
    t.integer "att_agg"
    t.integer "att_ant"
    t.integer "att_bra"
    t.integer "att_cmp"
    t.integer "att_cnt"
    t.integer "att_dec"
    t.integer "att_det"
    t.integer "att_fla"
    t.integer "att_ldr"
    t.integer "att_otb"
    t.integer "att_pos"
    t.integer "att_tea"
    t.integer "att_vis"
    t.integer "att_wor"
    t.integer "att_acc"
    t.integer "att_agi"
    t.integer "att_bal"
    t.integer "att_jum"
    t.integer "att_nat"
    t.integer "att_pac"
    t.integer "att_sta"
    t.integer "att_str"
    t.integer "att_aer"
    t.integer "att_cmd"
    t.integer "att_com"
    t.integer "att_ecc"
    t.integer "att_han"
    t.integer "att_kic"
    t.integer "att_1v1"
    t.integer "att_pun"
    t.integer "att_ref"
    t.integer "att_tro"
    t.integer "att_thr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "foot_right"
    t.integer "foot_left"
    t.integer "age"
    t.integer "height"
    t.integer "potential"
    t.string "position_string"
    t.index ["player_id"], name: "index_player_snapshots_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "scouted", default: false
    t.index ["name"], name: "index_players_on_name", unique: true
    t.index ["scouted"], name: "index_players_on_scouted"
  end

  create_table "tactic_roles", force: :cascade do |t|
    t.bigint "tactic_id", null: false
    t.integer "position"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tactic_id"], name: "index_tactic_roles_on_tactic_id"
  end

  create_table "tactics", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "player_snapshots", "players"
  add_foreign_key "tactic_roles", "tactics"
end
