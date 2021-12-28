class CreatePlaylistOfTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :playlist_of_tracks do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end
  end
end
