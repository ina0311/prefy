class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :tracks, through: :albums
  has_many :artist_genres, dependent: :destroy
  has_many :artist_genre_lists, through: :artist_genres, source: :genre
  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy

  with_options presence: true do
    validates :name
    validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/ }
  end

  scope :search_genre_names, ->(names) { where(artist_genre_lists: { name: names }) }

  def self.all_update(artist_attributes)
    Genre.all_import(artist_attributes.pluck(:genres).flatten.uniq) if artist_attributes.pluck(:genres).present?

    Artist.transaction do
      artists = artist_attributes.map do |artist|
                  Artist.new(
                    spotify_id: artist[:spotify_id],
                    name: artist[:name],
                    image: artist[:image]
                  )
                end

      Artist.import!(artists, on_duplicate_key_update: %i[name image])
    end

    artist_genres = artist_attributes.map { |artist| artist.slice(:spotify_id, :genres) }

    artist_genres.delete_if { |h| h[:genres].blank? }
    ArtistGenre.all_import(artist_genres)
  end
end
