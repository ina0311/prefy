class CreateTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :tracks, id: false do |t|
      t.string :spotify_id, null: false, primary_key: true
      t.string :name, null: false
      t.integer :duration_ms, null: false
      t.references :album, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :tracks, :albums, column: :album_id, primary_key: :spotify_id
  end
end
