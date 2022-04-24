class AddPositionToPlaylistOfTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :playlist_of_tracks, :position, :integer, null: false
  end
end
