class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでuniquenessはつけない

  def self.all_update(attributes, playlist_id)
    PlaylistOfTrack.transaction do
      playlist_of_tracks = attributes.map do |atr|
                            PlaylistOfTrack.new(playlist_id: playlist_id, track_id: atr[:spotify_id])
                          end

      PlaylistOfTrack.import!(playlist_of_tracks)
    end
  end
end
