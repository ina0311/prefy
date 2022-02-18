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
    Genre.all_import!(@response)
    Artist.all_update(@response)
    ArtistGenre.all_import!(@response)
    ArtistAndAlbum.all_import!(@albums) if @albums.present?
  end
end