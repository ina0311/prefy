class CreateTrackGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :track_genres do |t|
      t.references :track, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
    add_index :track_genres, [:track_id, :genre_id], unique: true
  end
end
