class Albums::AlbumRegistrar < SpotifyService
  def self.call(tracks)
    new(tracks).register
  end

  def initialize(tracks)
    @tracks = tracks
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
    while true
      response.concat(RSpotify::Album.find(ids[offset, 20]))
      offset += 20
      break if response.size != offset
    end
    response
  end
end