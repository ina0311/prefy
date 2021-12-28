class CreateArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :artists do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.string :image, null: false

      t.timestamps
    end
  end
end
