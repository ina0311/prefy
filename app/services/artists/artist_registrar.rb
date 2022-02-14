class Artists::ArtistRegistrar < SpotifyService
  def self.call(ids, *albums)
    new(ids, *albums).register
  end

  def initialize(ids, *albums)
    @ids = ids.flatten
    @albums = albums.flatten
  end

  def register
    @response = request_artists_info(@ids)
    Genre.all_import(@response)
    Artist.all_update(@response)
    ArtistGenre.all_import(convert_artist_and_genre_names)
    ArtistAndAlbum.all_insert(@albums) if @albums.present?
  end

  private

  def convert_artist_and_genre_names
    artist_and_genres = @response.map do |res| 
                          next if res.genres.blank?
                          {
                            artist_id: res.id, 
                            genre_names: res.genres 
                          }
                        end
    artist_and_genres.compact
  end
end