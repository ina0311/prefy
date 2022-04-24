class SavedPlaylists::BasedOnSavedPlaylistTracksGetter < SpotifyService
  # saved_playlistの情報からクエリを作成、曲を取得、絞り込み
  def self.call(saved_playlist)
    new(saved_playlist).get
  end

  def initialize(saved_playlist)
    @saved_playlist = saved_playlist
  end
  
  def get
    fillter = saved_playlist.convert_fillter
    querys, target_querys = saved_playlist.convert_querys(fillter)
    ramdom_tracks = search_tracks(querys).flatten
    target_tracks = search_tracks(target_querys) if target_querys.present?
    return false if ramdom_tracks.nil? && target_tracks.nil?

    refined_ramdom_and_target_tracks = refine_tracks(ramdom_tracks, target_tracks)
    return refined_ramdom_and_target_tracks
  end

  private

  attr_reader :saved_playlist

  def search_tracks(querys)
    response = request_search_tracks(querys)
    return response if response.nil?

    tracks = response_convert_tracks(response)
    return tracks
  end

  def request_search_tracks(querys)
    tracks = []
    querys.each do |query|
      response = RSpotify::Base.search(query[:query], 'track', limit: 50)
      artist_tracks = []
      response.each do |res|
        # アルバムのタイプがコンピレーション、または違うアーティストの曲は弾く
        next if res.album.album_type == 'compilation' || res.artists.map { |artist| artist.id != query[:artist_spotify_id] }.all?
        artist_tracks << res
      end
      tracks << artist_tracks.compact
    end
    tracks = nil unless tracks.flatten.any?
    return tracks
  end

  def response_convert_tracks(response)
    tracks = []
    response.each do |res|
      next if res.blank?
      artist_tracks = []
      res.each do |r|
        # アーティストの同じ名前の曲を弾く
        next if artist_tracks.pluck(:name).include?(r.name)
        artist_tracks << {track_id: r.id, name: r.name, duration_ms: r.duration_ms}
      end
      tracks << artist_tracks
    end
    return tracks
  end

  def refine_tracks(ramdom_tracks, target_tracks)
    if saved_playlist.max_total_duration_ms.present?
      return saved_playlist.refine_by_duration_ms(ramdom_tracks, target_tracks)
    else
      return saved_playlist.refine_by_max_number_of_track(ramdom_tracks, target_tracks)
    end
  end
end