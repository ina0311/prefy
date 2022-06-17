class AddPositionToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :position, :integer, null: false
  end
end
