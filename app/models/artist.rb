class Artist < ApplicationRecord
  has_many :artist_and_albums, dependent: :destroy
  has_many :albums, through: :artist_and_albums
  has_many :tracks, through: :albums
  has_many :artist_genres, dependent: :destroy
  has_many :artist_genre_lists, through: :artist_genres, source: :genre
  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy

  validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/, allow_nil: true }
  validates :name, presence: true

  scope :search_genre_names, ->(names) { where(artist_genre_lists: { name: names }) }

  def self.all_update(response)
    Artist.transaction do
      artists = response.map do |res|
                  Artist.new(
                    spotify_id: res.id,
                    name: res.name,
                    image: res.images.dig(0, 'url')
                  )
                end
      Artist.import!(artists, on_duplicate_key_update: %i[name image])
    end
  end
end
