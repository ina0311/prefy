class CreateSavedPlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlists do |t|
      t.boolean :only_follow_artist
      t.integer :that_generation_preference
      t.string :period
      t.integer :max_number_of_track
      t.integer :max_total_duration_ms
      t.references :user, null: false, type: :string
      t.references :playlist, null: false, type: :string

      t.timestamps
    end
    add_foreign_key :saved_playlists, :users, column: :user_id , primary_key: :spotify_id
    add_foreign_key :saved_playlists, :playlists, column: :playlist_id , primary_key: :spotify_id
    add_index :saved_playlists, [:user_id, :playlist_id], unique: true
  end
end
