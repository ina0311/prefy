class CreatePlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :playlists do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.string :image
      t.string :owner, null: false

      t.timestamps
    end
    add_index :playlists, [:spotify_id], unique: true
  end
end
