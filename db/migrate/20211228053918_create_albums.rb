class CreateAlbums < ActiveRecord::Migration[6.1]
  def change
    create_table :albums, id: false do |t|
      t.string :spotify_id, null: false, primary_key: true
      t.string :name, null: false
      t.string :image, null: false
      t.string :release_date, null: false
      t.references :artist, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :albums, :artists, column: :artist_id, primary_key: :spotify_id
  end
end
