class ArtistAndAlbum < ApplicationRecord
  belongs_to :artist
  belongs_to :album

  validates :artist_id, uniqueness: { scope: :album_id }

  def self.all_import!(albums)
    ArtistAndAlbum.transaction do
      objects = albums.map do |album|
        album[:artists].map do |artist|
          ArtistAndAlbum.new(
            artist_id: artist[:id],
            album_id: album[:id]
          )
        end
      end
      ArtistAndAlbum.import!(objects.flatten, ignore: true)
    end
  end
end
