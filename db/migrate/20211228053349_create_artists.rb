class CreateArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :artists do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.string :image

      t.timestamps
    end
    add_index :artists, [:spotify_id], unique: true
  end
end
