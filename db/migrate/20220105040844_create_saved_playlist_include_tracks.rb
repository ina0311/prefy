class CreateSavedPlaylistIncludeTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlist_include_tracks do |t|
      t.references :saved_playlist, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end
    add_index :saved_playlist_include_tracks, [:saved_playlist_id, :track_id], unique: true, name: 'saved_playlist_and_track_index'
  end
end
