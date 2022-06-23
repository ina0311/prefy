class AddPositionToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :position, :integer, null: false, default: 0
    add_index :tracks, [:album_id, :position], unique: true
  end
end
