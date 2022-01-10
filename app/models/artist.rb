class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :saved_playlist_include_artists, dependent: :destroy
end
