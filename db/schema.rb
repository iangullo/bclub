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

ActiveRecord::Schema.define(version: 2021_08_09_164700) do

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "sex"
    t.integer "min_years"
    t.integer "max_years"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "coaches", force: :cascade do |t|
    t.boolean "active"
    t.integer "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_coaches_on_person_id"
  end

  create_table "coaches_teams", id: false, force: :cascade do |t|
    t.integer "coach_id", null: false
    t.integer "team_id", null: false
  end

  create_table "divisions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "drills", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "material"
    t.integer "coach_id", null: false
    t.integer "kind_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coach_id"], name: "index_drills_on_coach_id"
    t.index ["kind_id"], name: "index_drills_on_kind_id"
  end

  create_table "drills_skills", id: false, force: :cascade do |t|
    t.integer "drill_id", null: false
    t.integer "skill_id", null: false
  end

  create_table "exercises", force: :cascade do |t|
    t.integer "training_session_id", null: false
    t.integer "order"
    t.integer "drill_id", null: false
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["drill_id"], name: "index_exercises_on_drill_id"
    t.index ["training_session_id"], name: "index_exercises_on_training_session_id"
  end

  create_table "kinds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "gmaps_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "practice_court"
  end

  create_table "people", force: :cascade do |t|
    t.string "nick"
    t.string "name"
    t.string "surname"
    t.date "birthday"
    t.boolean "female"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "player_id", null: false
    t.integer "coach_id", null: false
    t.index ["coach_id"], name: "index_people_on_coach_id"
    t.index ["player_id"], name: "index_people_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "number"
    t.boolean "active"
    t.integer "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_players_on_person_id"
  end

  create_table "players_teams", id: false, force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "team_id", null: false
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.integer "category_id", null: false
    t.integer "division_id", null: false
    t.integer "season_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "homecourt_id"
    t.index ["category_id"], name: "index_teams_on_category_id"
    t.index ["division_id"], name: "index_teams_on_division_id"
    t.index ["homecourt_id"], name: "index_teams_on_homecourt_id"
    t.index ["season_id"], name: "index_teams_on_season_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.integer "team_id", null: false
    t.date "date"
    t.integer "training_slot_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "location_id"
    t.time "start"
    t.integer "duration"
    t.string "targets"
    t.index ["location_id"], name: "index_training_sessions_on_location_id"
    t.index ["team_id"], name: "index_training_sessions_on_team_id"
    t.index ["training_slot_id"], name: "index_training_sessions_on_training_slot_id"
  end

  create_table "training_slots", force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "location_id", null: false
    t.integer "wday"
    t.time "start"
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "team_id", default: 0
    t.index ["location_id"], name: "index_training_slots_on_location_id"
    t.index ["season_id"], name: "index_training_slots_on_season_id"
    t.index ["team_id"], name: "index_training_slots_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "coaches", "people"
  add_foreign_key "drills", "coaches"
  add_foreign_key "drills", "kinds"
  add_foreign_key "exercises", "drills"
  add_foreign_key "exercises", "training_sessions"
  add_foreign_key "people", "coaches"
  add_foreign_key "people", "players"
  add_foreign_key "players", "people"
  add_foreign_key "teams", "categories"
  add_foreign_key "teams", "divisions"
  add_foreign_key "teams", "locations", column: "homecourt_id"
  add_foreign_key "teams", "seasons"
  add_foreign_key "training_sessions", "teams"
  add_foreign_key "training_sessions", "training_slots"
  add_foreign_key "training_slots", "locations"
  add_foreign_key "training_slots", "seasons"
  add_foreign_key "training_slots", "teams"
end
