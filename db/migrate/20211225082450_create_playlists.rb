class CreatePlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :playlists do |t|
      t.string :spotify_id, null: false
      t.string :name, null: false
      t.string :image
      t.string :owner, null: false
      t.boolean :only_follow_artist
      t.integer :that_generation_preference
      t.integer :max_number_of_track
      t.integer :max_total_duration_ms
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
