class ArtistAndAlbum < ApplicationRecord
  belongs_to :artist
  belongs_to :album

  validates :artist_id, uniqueness: { scope: :album_id }
end
