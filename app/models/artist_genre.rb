class ArtistGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :artist_id, uniqueness: { scope: :genre_id }

  class << self
    def all_import!(response)
      ArtistGenre.transaction do
        artist_and_genre_names = convert_artist_and_genre_names(response)
        artist_genres = convert_artist_genres(artist_and_genre_names)
        ArtistGenre.import!(artist_genres, ignore: true)
      end
    end

    def convert_artist_genres(artist_and_genre_names)
      artist_genres = []
      genres = Genre.search_by_names(artist_and_genre_names)

      artist_and_genre_names.map do |hash|
        match_genres = genres.select do |genre|
          hash[:genre_names].include?(genre.name)
        end
        artist_genres.concat(
          match_genres.map do |genre|
            ArtistGenre.new(
              artist_id: hash[:artist_id],
              genre_id: genre[:id]
            )
          end
        )
      end

      artist_genres
    end

    def convert_artist_and_genre_names(response)
      artist_and_genres = response.map do |res|
        next if res[:genres].blank?

        { artist_id: res[:id], genre_names: res[:genres] }
      end
      artist_and_genres.compact
    end
  end
end
