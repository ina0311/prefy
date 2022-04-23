class RemoveArtistIdFromAlbums < ActiveRecord::Migration[6.1]
  def change
    remove_reference :albums, :artist, null: false, foreign_key: true
  end
end
