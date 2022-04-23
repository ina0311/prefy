class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでuniquenessはつけない
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :specific, ->(playlist_id, positions) { where(playlist_id: playlist_id).where(position: positions) }
  
  def self.all_update(playlist, track_ids)
    PlaylistOfTrack.transaction do
      playlist_of_tracks = track_ids.map.with_index do |id, index|
                            playlist.playlist_of_tracks.new(track_id: id, position: index)
                          end

      PlaylistOfTrack.import!(playlist_of_tracks)
    end
  end
end
