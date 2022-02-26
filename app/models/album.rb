class Album < ApplicationRecord
  has_many :artist_and_albums, dependent: :destroy
  has_many :artists, through: :artist_and_albums
  has_many :tracks, dependent: :destroy

  with_options presence: true do
    validates :name
    validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/ }
    validates :release_date, format: { with: /\A\d{4}[-\d{2}]*[-\d{2}]*\z/ }
  end

  attribute :artist_names

  def self.all_import!(response)
    Album.transaction do
      albums = response.map do |res|
                Album.new(
                  spotify_id: res.id,
                  name: res.name,
                  image: res.images.dig(0, 'url'),
                  release_date: res.release_date
                )
              end
      Album.import!(albums, ignore: true)
    end
  end

  def self.find_or_create_by_response!(response)
    Album.find_or_create_by!(
      spotify_id: response.id,
      name: response.name,
      image: response.images.dig(0, 'url'),
      release_date: response.release_date
    )
  end
end
