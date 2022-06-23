class Artists::ArtistRegistrar < SpotifyService
  def self.call(user, ids, *albums)
    new(user: user, ids: ids, albums: albums.flatten!).register
  end

  def register
    response = request_artists_info
    Genre.all_import!(response)
    Artist.all_import!(response)
    ArtistGenre.all_import!(response)
    ArtistAndAlbum.all_import!(albums) if albums.present?
  end

  private

  attr_reader :user, :ids, :albums

  def request_artists_info
    response = []
    offset = 0
    loop do
      response.concat(conn_request.get("artists?ids=#{ids[offset, 50].join(',')}").body[:artists])
      break if response.size == ids.size

      offset += 50
    end
    response
  end
end
