class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでuniquenessはつけない

  scope :specific, ->(playlist_id, track_ids) { where(playlist_id: playlist_id).where(track_id: track_ids) }
  def self.all_update(playlist_id, track_ids)
    PlaylistOfTrack.transaction do
      playlist_of_tracks = track_ids.map do |id|
                            PlaylistOfTrack.new(playlist_id: playlist_id, track_id: id)
                          end

      PlaylistOfTrack.import!(playlist_of_tracks)
    end
  end
end
