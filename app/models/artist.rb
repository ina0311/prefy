class Artist < ApplicationRecord
  has_many :artist_and_albums, dependent: :destroy
  has_many :albums, through: :artist_and_albums
  has_many :tracks, through: :albums
  has_many :artist_genres, dependent: :destroy
  has_many :genres, through: :artist_genres, source: :genre
  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy
  has_many :users, through: :follow_artists, source: :user

  validates :image, format: { with: %r(\Ahttps://i.scdn.co/image/[a-z0-9]+\z), allow_nil: true }
  validates :name, presence: true

  scope :search_genre_names, ->(names) { where(genres: { name: names }) }

  def self.all_import!(response)
    Artist.transaction do
      artists = response.map do |res|
        Artist.new(
          spotify_id: res[:id],
          name: res[:name],
          image: res.dig(:images, 0, :url)
        )
      end
      Artist.import!(artists, on_duplicate_key_update: %i[name image])
    end
  end
end
