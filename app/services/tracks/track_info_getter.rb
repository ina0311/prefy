class Tracks::TrackInfoGetter < SpotifyService
  # 曲の取得、保存
  def self.call(track_ids)
    new(track_ids).get
  end

  def initialize(track_ids)
    @track_ids = track_ids
  end

  def get
    tracks = request_get_tracks
    albums = tracks.map(&:album)
    Album.all_import!(albums)
    Track.all_import!(tracks)
    Artists::ArtistRegistrar.call(track_convert_artist_ids(tracks), albums)
  end

  private

  attr_reader :track_ids

  def track_convert_artist_ids(tracks)
    tracks.map { |track| track.artists.map(&:id) }.flatten
  end

  def request_get_tracks
    offset = 0
    response = []
    while true
      response.concat(RSpotify::Track.find(@track_ids[offset, 50]))
      break if response.size == @track_ids.size
      offset += 50
    end
    response
  end
end