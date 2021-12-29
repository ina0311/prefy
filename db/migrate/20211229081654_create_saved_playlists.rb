class CreateSavedPlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlists do |t|
      t.boolean :only_follow_artist
      t.integer :that_generation_prefernce
      t.integer :max_number_of_track
      t.integer :max_total_duration_ms
      t.references :user, null: false, foreign_key: true
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
    add_index :saved_playlists, [:user_id, :playlist_id], unique: true
  end
end
