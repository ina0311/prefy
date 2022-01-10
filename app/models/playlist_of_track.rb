class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでuniquenessはつけない
end
