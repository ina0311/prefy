class Tracks::TrackInfoGetter < SpotifyService
  # 曲の取得、保存
  def self.call(user, track_ids)
    new(user, track_ids).get
  end

  def initialize(user, track_ids)
    @user = user
    @track_ids = track_ids
  end

  def get
    tracks = request_get_tracks
    albums = tracks.map { |t| t[:album] }
    Album.all_import!(albums)
    Track.all_import!(tracks)
    Artists::ArtistRegistrar.call(user, track_convert_artist_ids(tracks), albums)
  end

  private

  attr_reader :user, :track_ids

  def track_convert_artist_ids(tracks)
    tracks.map { |track| track[:artists].map { |artist| artist[:id] } }.flatten
  end

  def request_get_tracks
    offset = 0
    response = []
    while true
      response.concat(conn_request.get("tracks?ids=#{track_ids[offset, 50].join(',')}").body[:tracks])
      break if response.size == track_ids.size
      offset += 50
    end
    response
  end
end