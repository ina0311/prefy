class CreateTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :tracks do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.integer :duration_ms, null: false
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
  end
end
