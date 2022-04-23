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

ActiveRecord::Schema.define(version: 2022_03_16_133505) do

  create_table "albums", primary_key: "spotify_id", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "image", null: false
    t.string "release_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "artist_and_albums", charset: "utf8mb3", force: :cascade do |t|
    t.string "artist_id", null: false
    t.string "album_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_id"], name: "index_artist_and_albums_on_album_id"
    t.index ["artist_id", "album_id"], name: "index_artist_and_albums_on_artist_id_and_album_id", unique: true
    t.index ["artist_id"], name: "index_artist_and_albums_on_artist_id"
  end

  create_table "artist_genres", charset: "utf8mb3", force: :cascade do |t|
    t.string "artist_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id", "genre_id"], name: "index_artist_genres_on_artist_id_and_genre_id", unique: true
    t.index ["artist_id"], name: "index_artist_genres_on_artist_id"
    t.index ["genre_id"], name: "index_artist_genres_on_genre_id"
  end

  create_table "artists", primary_key: "spotify_id", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "follow_artists", charset: "utf8mb3", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "artist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_follow_artists_on_artist_id"
    t.index ["user_id", "artist_id"], name: "index_follow_artists_on_user_id_and_artist_id", unique: true
    t.index ["user_id"], name: "index_follow_artists_on_user_id"
  end

  create_table "genres", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "playlist_of_tracks", charset: "utf8mb3", force: :cascade do |t|
    t.string "playlist_id", null: false
    t.string "track_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position", null: false
    t.index ["playlist_id"], name: "index_playlist_of_tracks_on_playlist_id"
    t.index ["track_id"], name: "index_playlist_of_tracks_on_track_id"
  end

  create_table "playlists", primary_key: "spotify_id", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "image"
    t.string "owner", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "saved_playlist_genres", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "saved_playlist_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["genre_id"], name: "index_saved_playlist_genres_on_genre_id"
    t.index ["saved_playlist_id", "genre_id"], name: "index_saved_playlist_genres_on_saved_playlist_id_and_genre_id", unique: true
    t.index ["saved_playlist_id"], name: "index_saved_playlist_genres_on_saved_playlist_id"
  end

  create_table "saved_playlist_include_artists", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "saved_playlist_id", null: false
    t.string "artist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_saved_playlist_include_artists_on_artist_id"
    t.index ["saved_playlist_id", "artist_id"], name: "saved_playlist_and_artist_index", unique: true
    t.index ["saved_playlist_id"], name: "index_saved_playlist_include_artists_on_saved_playlist_id"
  end

  create_table "saved_playlist_include_tracks", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "saved_playlist_id", null: false
    t.string "track_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["saved_playlist_id", "track_id"], name: "saved_playlist_and_track_index", unique: true
    t.index ["saved_playlist_id"], name: "index_saved_playlist_include_tracks_on_saved_playlist_id"
    t.index ["track_id"], name: "index_saved_playlist_include_tracks_on_track_id"
  end

  create_table "saved_playlists", charset: "utf8mb3", force: :cascade do |t|
    t.boolean "only_follow_artist"
    t.integer "that_generation_preference"
    t.string "period"
    t.integer "max_number_of_track"
    t.integer "max_total_duration_ms"
    t.string "user_id", null: false
    t.string "playlist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_saved_playlists_on_playlist_id"
    t.index ["user_id", "playlist_id"], name: "index_saved_playlists_on_user_id_and_playlist_id", unique: true
    t.index ["user_id"], name: "index_saved_playlists_on_user_id"
  end

  create_table "tracks", primary_key: "spotify_id", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration_ms", null: false
    t.string "album_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
  end

  create_table "users", primary_key: "spotify_id", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "image"
    t.string "country", null: false
    t.integer "age"
    t.text "encrypted_access_token"
    t.text "encrypted_access_token_iv"
    t.text "encrypted_refresh_token"
    t.text "encrypted_refresh_token_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "artist_and_albums", "albums", primary_key: "spotify_id"
  add_foreign_key "artist_and_albums", "artists", primary_key: "spotify_id"
  add_foreign_key "artist_genres", "artists", primary_key: "spotify_id"
  add_foreign_key "artist_genres", "genres"
  add_foreign_key "follow_artists", "artists", primary_key: "spotify_id"
  add_foreign_key "follow_artists", "users", primary_key: "spotify_id"
  add_foreign_key "playlist_of_tracks", "playlists", primary_key: "spotify_id"
  add_foreign_key "playlist_of_tracks", "tracks", primary_key: "spotify_id"
  add_foreign_key "saved_playlist_genres", "genres"
  add_foreign_key "saved_playlist_genres", "saved_playlists"
  add_foreign_key "saved_playlist_include_artists", "artists", primary_key: "spotify_id"
  add_foreign_key "saved_playlist_include_artists", "saved_playlists"
  add_foreign_key "saved_playlist_include_tracks", "saved_playlists"
  add_foreign_key "saved_playlist_include_tracks", "tracks", primary_key: "spotify_id"
  add_foreign_key "saved_playlists", "playlists", primary_key: "spotify_id"
  add_foreign_key "saved_playlists", "users", primary_key: "spotify_id"
  add_foreign_key "tracks", "albums", primary_key: "spotify_id"
end
