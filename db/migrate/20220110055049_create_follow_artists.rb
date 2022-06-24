class CreateFollowArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :follow_artists do |t|
      t.references :user, null: false, type: :string
      t.references :artist, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :follow_artists, :users, column: :user_id, primary_key: :spotify_id
    add_foreign_key :follow_artists, :artists, column: :artist_id, primary_key: :spotify_id
    add_index :follow_artists, [:user_id, :artist_id], unique: true
  end
end
