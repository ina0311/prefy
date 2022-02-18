class Tracks::TrackInfoGetter < SpotifyService
  # 曲の取得、保存
  def self.call(track_ids)
    new(track_ids).get
  end

  def initialize(track_ids)
    @track_ids = track_ids
  end

  def get
    tracks = request_get_tracks(@track_ids)
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
end