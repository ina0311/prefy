class CreateArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :artists, id: false do |t|
      t.string :spotify_id, null: false, primary_key: true
      t.string :name, null: false
      t.string :image

      t.timestamps
    end
  end
end
