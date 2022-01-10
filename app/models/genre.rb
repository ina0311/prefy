class Genre < ApplicationRecord
  has_many :track_genres, dependent: :destroy
  has_many :saved_playlist_genres, dependent: :destroy
end
