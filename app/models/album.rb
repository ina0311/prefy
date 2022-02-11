class Album < ApplicationRecord
  has_many :artist_and_albums, dependent: :destroy
  has_many :artists, through: :artist_and_albums
  has_many :tracks, dependent: :destroy

  with_options presence: true do
    validates :name
    validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/ }
    validates :release_date, format: { with: /\A\d{4}[-\d{2}]*[-\d{2}]*\z/ }
  end


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
