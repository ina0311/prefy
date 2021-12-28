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

ActiveRecord::Schema.define(version: 2021_12_25_082450) do

  create_table "playlists", charset: "utf8mb3", force: :cascade do |t|
    t.string "spotify_id", null: false
    t.string "name", null: false
    t.string "image"
    t.string "owner", null: false
    t.boolean "only_follow_artist"
    t.integer "that_generation_preference"
    t.integer "max_number_of_track"
    t.integer "max_total_duration_ms"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "image"
    t.string "country", null: false
    t.string "spotify_id", null: false
    t.integer "age"
    t.text "encrypted_access_token"
    t.text "encrypted_access_token_iv"
    t.text "encrypted_refresh_token"
    t.text "encrypted_refresh_token_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "playlists", "users"
end
