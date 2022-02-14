class ArtistGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :artist_id, uniqueness: { scope: :genre_id }

  def self.all_import(artist_and_genre_names)
    ArtistGenre.transaction do
      artist_genres = convert_artist_genres(artist_and_genre_names)
      ArtistGenre.import!(artist_genres, ignore: true)
    end
  end

  def self.convert_artist_genres(artist_and_genre_names)
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
end
