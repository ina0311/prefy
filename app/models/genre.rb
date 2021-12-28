class Genre < ApplicationRecord
  has_many :track_genres, dependent: :destroy
end
