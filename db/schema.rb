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

ActiveRecord::Schema.define(version: 2021_12_29_081654) do

  create_table "albums", charset: "utf8mb3", force: :cascade do |t|
    t.string "spotify_id", null: false
    t.string "name", null: false
    t.string "image", null: false
    t.string "release_date", null: false
    t.bigint "artist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
  end

  create_table "artists", charset: "utf8mb3", force: :cascade do |t|
    t.string "spotify_id", null: false
    t.string "name", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "genres", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "playlist_of_tracks", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "track_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_playlist_of_tracks_on_playlist_id"
    t.index ["track_id"], name: "index_playlist_of_tracks_on_track_id"
  end

  create_table "playlists", charset: "utf8mb3", force: :cascade do |t|
    t.string "spotify_id", null: false
    t.string "name", null: false
    t.string "image"
    t.string "owner", null: false
    t.boolean "only_follow_artist"
    t.integer "that_generation_preference"
    t.integer "max_number_of_track"
    t.integer "max_total_duration_ms"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "saved_playlists", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "playlist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_saved_playlists_on_playlist_id"
    t.index ["user_id"], name: "index_saved_playlists_on_user_id"
  end

  create_table "track_genres", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["genre_id"], name: "index_track_genres_on_genre_id"
    t.index ["track_id"], name: "index_track_genres_on_track_id"
  end

  create_table "tracks", charset: "utf8mb3", force: :cascade do |t|
    t.string "spotify_id", null: false
    t.string "name", null: false
    t.integer "duration_ms", null: false
    t.bigint "album_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
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

  add_foreign_key "albums", "artists"
  add_foreign_key "playlist_of_tracks", "playlists"
  add_foreign_key "playlist_of_tracks", "tracks"
  add_foreign_key "saved_playlists", "playlists"
  add_foreign_key "saved_playlists", "users"
  add_foreign_key "track_genres", "genres"
  add_foreign_key "track_genres", "tracks"
  add_foreign_key "tracks", "albums"
end
