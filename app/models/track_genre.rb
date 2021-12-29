class TrackGenre < ApplicationRecord
  belongs_to :track
  belongs_to :genre

  validates :track_id, uniqueness: { scope: :genre_id }
end
