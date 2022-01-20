class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks, dependent: :destroy

  def self.all_insert(album_attributes)
    Album.transaction do
      albums = album_attributes.map do |album|
                Album.new(
                  spotify_id: album[:spotify_id],
                  name: album[:name],
                  image: album[:image],
                  release_date: album[:release_date],
                  artist_id: album[:artist_spotify_id]
                )
              end
      
      Album.import!(albums, ignore: true)
    end
  end
end
