class Albums::AlbumRegistrar < SpotifyService
  def self.call(tracks)
    new(tracks: tracks).register
  end

  def register
    ids = uniq_album_ids
    albums = request_album_info(ids)
    Album.all_import!(albums)
    albums
  end

  private

  attr_reader :tracks

  def uniq_album_ids
    tracks.pluck(:album_id).uniq
  end

  def request_album_info(ids)
    offset = 0
    response = []
    loop do
      response.concar(conn_request.get("albums?ids=#{ids[offset, 20].join(',')}").body[:albums])
      offset += 20
      break if response.size != offset
    end
    response
  end
end
