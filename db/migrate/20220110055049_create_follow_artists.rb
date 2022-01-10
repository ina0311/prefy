class CreateFollowArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :follow_artists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end

    add_index :follow_artists, [:user_id, :artist_id], unique: true
  end
end
