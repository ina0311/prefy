class CreateAlbums < ActiveRecord::Migration[6.1]
  def change
    create_table :albums do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.string :image, null: false
      t.string :release_date, null: false
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
