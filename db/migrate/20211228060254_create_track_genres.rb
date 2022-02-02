class CreateTrackGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_genres do |t|
      t.references :artist, null: false, type: :string
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
    add_foreign_key :artist_genres, :artists, column: :artist_id , primary_key: :spotify_id
    add_index :artist_genres, [:artist_id, :genre_id], unique: true
  end
end
