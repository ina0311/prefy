class Artists::ArtistRegistrar < SpotifyService
  def self.call(ids, *albums)
    new(ids, *albums).register
  end

  def initialize(ids, *albums)
    @ids = ids.flatten
    @albums = albums.flatten
  end

  def register
    response = request_artists_info
    Genre.all_import!(response)
    Artist.all_update(response)
    ArtistGenre.all_import!(response)
    ArtistAndAlbum.all_import!(albums) if albums.present?
  end

  private

  attr_reader :ids, :albums

  def request_artists_info
    response = []
    offset = 0
    while true
      response.concat(RSpotify::Artist.find(ids[offset, 50]))
      break if response.size == @ids.size
      offset += 50
    end
    response
  end
end