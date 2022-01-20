class ArtistGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :artist_id, uniqueness: { scope: :genre_id }

  def self.all_import(artist_genres)
    artist_genre_attributes = []
    ArtistGenre.transaction do
      artist_genres.map do |artist_genre|
        Genre.where(name: artist_genre[:genres]).ids.map do |genre_id|
          attributes = ArtistGenre.new(
                         artist_id: artist_genre[:spotify_id],
                         genre_id: genre_id
                       )
          artist_genre_attributes << attributes
        end
      end

      ArtistGenre.import!(artist_genre_attributes, ignore: true)
    end
  end
end
