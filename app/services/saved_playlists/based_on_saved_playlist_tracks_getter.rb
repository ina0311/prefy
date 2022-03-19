class SavedPlaylists::BasedOnSavedPlaylistTracksGetter < SpotifyService
  # saved_playlistの情報からクエリを作成、曲を取得、絞り込み
  def self.call(saved_playlist)
    new(saved_playlist).get
  end

  def initialize(saved_playlist)
    @saved_playlist = saved_playlist
  end
  
  def get
    querys, target_querys = saved_playlist.create_querys
    @tracks = search_tracks(querys).flatten!
    @target_tracks = search_tracks(target_querys) if target_querys.present?
    check_tracks
    saved_playlist.refine_tracks(@tracks, @target_tracks)
  end

  private

  attr_reader :saved_playlist

  # 条件にあった曲がない場合にnil
  def check_tracks
    @tracks = nil unless @tracks&.any?
    @target_tracks = nil unless @target_tracks&.flatten&.any?
  end

  def search_tracks(querys)
    response = request_search_tracks(querys)
    tracks = Track.response_convert_tracks(response)
  end

  def request_search_tracks(querys)
    tracks = []
    querys.each do |query|
      response = RSpotify::Base.search(query[:query], 'track', limit: 50)
      artist_tracks = []
      response.each do |res|
        next if res.album.album_type == 'compilation' || res.artists.map { |artist| artist.id != query[:artist_spotify_id] }.all?
        artist_tracks << res
      end
      tracks << artist_tracks.compact
    end
    tracks
  end
end