class Track < ApplicationRecord
  belongs_to :album

  has_many :playlist_of_tracks, dependent: :destroy
  has_many :track_genres, dependent: :destroy
  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :saved_playlists, through: :saved_playlist_include_tracks
end
