class CreateSavedPlaylistGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlist_genres do |t|
      t.references :saved_playlist, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
    add_index :saved_playlist_genres, [:saved_playlist_id, :genre_id], unique: true
  end
end
