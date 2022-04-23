class CreateArtistAndAlbums < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_and_albums do |t|
      t.references :artist, null: false, type: :string
      t.references :album, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :artist_and_albums, :artists, column: :artist_id, primary_key: :spotify_id
    add_foreign_key :artist_and_albums, :albums, column: :album_id, primary_key: :spotify_id
    add_index :artist_and_albums, [:artist_id, :album_id], unique: true
  end
end
