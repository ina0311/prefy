class CreateSavedPlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_playlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
