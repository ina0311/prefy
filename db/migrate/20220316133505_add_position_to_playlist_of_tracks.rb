class AddPositionToPlaylistOfTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :playlist_of_tracks, :position, :integer, null: false, default: 0
    add_index :playlist_of_tracks, [:playlist_id, :position], unique: true
  end
end
