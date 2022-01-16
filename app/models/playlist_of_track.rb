class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでuniquenessはつけない
  def self.add_tracks(track_attributes)
    
  end

  def self.all_update(attributes)

  end
end
