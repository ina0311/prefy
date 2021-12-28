class Track < ApplicationRecord
  belongs_to :album
  has_many :playlist_of_tracks, dependent: :destroy
end
