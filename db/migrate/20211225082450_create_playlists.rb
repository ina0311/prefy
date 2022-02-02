class CreatePlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :playlists, id: false do |t|
      t.string :spotify_id, null: false, primary_key: true
      t.string :name, null: false
      t.string :image
      t.string :owner, null: false

      t.timestamps
    end
  end
end
