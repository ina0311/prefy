class CreateSavedPlaylistIncludeArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlist_include_artists do |t|
      t.references :saved_playlist, null: false, foreign_key: true
      t.references :artist, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :saved_playlist_include_artists, :artists, column: :artist_id, primary_key: :spotify_id
    add_index :saved_playlist_include_artists, [:saved_playlist_id, :artist_id], unique: true, name: 'saved_playlist_and_artist_index'
  end
end
