class ArtistGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :artist_id, uniqueness: { scope: :genre_id }

  def self.all_import(artist_genres)
    artist_genre_attributes = []
    artist_id_and_genre_id_list = []

    genres = Genre.where(name: artist_genres.pluck(:genres).flatten.uniq)
    genre_id_and_name = genres.map { |h| h.attributes.symbolize_keys.slice(:id, :name) }
    artist_genres.map do |hash|
      genres_id_and_name = genre_id_and_name.select { |id_and_name| hash[:genres].include?(id_and_name[:name]) }
      genres_id_and_name.each do |id_and_name|
        genre_id = id_and_name.slice(:id)
        artist_id_and_genre_id = genre_id.merge(artist_id: hash[:spotify_id])
        artist_id_and_genre_id_list << artist_id_and_genre_id
      end
    end
    
    ArtistGenre.transaction do
      artist_id_and_genre_id_list.each do |artist_genre|
        attributes = ArtistGenre.new(
                        artist_id: artist_genre[:artist_id],
                        genre_id: artist_genre[:id]
                      )
        artist_genre_attributes << attributes
      end

      ArtistGenre.import!(artist_genre_attributes, ignore: true)
    end
  end
end
