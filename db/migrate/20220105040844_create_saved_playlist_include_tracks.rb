class CreateSavedPlaylistIncludeTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlist_include_tracks do |t|
      t.references :saved_playlist, null: false, foreign_key: true
      t.references :track, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :saved_playlist_include_tracks, :tracks, column: :track_id , primary_key: :spotify_id
    add_index :saved_playlist_include_tracks, [:saved_playlist_id, :track_id], unique: true, name: 'saved_playlist_and_track_index'
  end
end
