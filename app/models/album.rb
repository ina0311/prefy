class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks, dependent: :destroy

  def self.all_update(album_attributes)

    Album.transaction do
      albums = album_attributes.map do |album|
                Album.new(
                  spotify_id: album[:spotify_id],
                  name: album[:name],
                  image: album[:image],
                  release_date: album[:release_date],
                  artist_id: search_arist(album[:artist_id])
                )
              end
    
      Album.import!(albums)
    end
  end

  def search_arist(spotify_id)
    Artist.find_by(spotify_id: spotify_id).id
  end
end
