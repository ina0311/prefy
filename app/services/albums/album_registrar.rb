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

  def uniq_album_ids
    @tracks.pluck(:album_id).uniq
  end
end