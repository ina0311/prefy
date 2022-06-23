class CreatePlaylistOfTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :playlist_of_tracks do |t|
      t.references :playlist, null: false, type: :string
      t.references :track, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :playlist_of_tracks, :playlists, column: :playlist_id, primary_key: :spotify_id
    add_foreign_key :playlist_of_tracks, :tracks, column: :track_id, primary_key: :spotify_id
  end
end
