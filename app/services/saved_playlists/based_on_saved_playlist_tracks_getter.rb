class SavedPlaylists::BasedOnSavedPlaylistTracksGetter < SpotifyService
  PERCENTAGE = 0.2
  DEFAULT = 50
  CHALLENGE = 3
  # saved_playlistの情報からクエリを作成、曲を取得、絞り込み
  def self.call(saved_playlist, user)
    new(saved_playlist: saved_playlist, user: user).get
  end

  def get
    year = saved_playlist.convert_year
    total_limit = if saved_playlist.max_number_of_track
                    saved_playlist.max_number_of_track
                  elsif saved_playlist.max_total_duration_ms
                    saved_playlist.max_total_duration_ms
                  else 
                    DEFAULT
                  end

    candidate_tracks = {ramdom_tracks: [], target_tracks: []}

    if saved_playlist.include_artists.present?
      target_ids = saved_playlist.include_artists.ids
      target_tracks = search_tracks(target_ids, year)
      candidate_tracks[:target_tracks] += tracks_narrow_by_artist(target_tracks, total_limit)
      total_limit -= limit_decrease(candidate_tracks[:target_tracks].flatten)
    end

    CHALLENGE.times do |t|
      if saved_playlist.only_follow_artist
        artist_ids = saved_playlist.call_artist_ids
        ramdom_tracks = search_tracks(artist_ids, year)
        candidate_tracks[:ramdom_tracks] += tracks_narrow_by_artist(ramdom_tracks, total_limit).flatten
      end
      total_limit -= limit_decrease(candidate_tracks[:ramdom_tracks])
      break if saved_playlist.meet_the_requirements?(candidate_tracks[:target_tracks] + candidate_tracks[:ramdom_tracks]) || total_limit <= 0
    end
    candidate_tracks[:ramdom_tracks].empty? && candidate_tracks[:target_tracks].empty? ? false : candidate_tracks
  end

  private

  attr_reader :saved_playlist, :user

  def search_tracks(ids, year)
    request_params = create_request_params(ids, year)
    request_search_tracks(request_params)
  end

  def create_request_params(ids, year)
    offset = INITIAL_VALUE
    response = []
    response.concat(conn_request(language: 'en').get("artists?ids=#{ids.join(',')}").body[:artists])
    response.map do |res|
      string = "artist:#{res[:name]}"
      string += year if year
      { id: res[:id], params: URI.encode_www_form_component(string) }
    end
  end

  def request_search_tracks(request_params)
    artists_tracks = request_params.map do |req|
      response = conn_request.get("search?q=#{req[:params]}&type=track").body[:tracks][:items]
      next if response.blank?
      response.delete_if { |res| should_remove_response?(res, req[:id]) }
    end
    artists_tracks.compact.map { |artist_track| artist_track.uniq { |track| track[:name] } }
  end

  def tracks_narrow_by_artist(artists_tracks, limit)
    refined_tracks = []
    artist_limit = limit * PERCENTAGE
    artists_tracks.shuffle.each do |artist_tracks|
      decrease = 0
      tracks = []
      saved_playlist.refine_tracks(artist_tracks, artist_limit).each do |track|
        refined_track = Track.new(
          spotify_id: track[:id],
          name: track[:name],
          duration_ms: track[:duration_ms],
          position: track[:track_number],
          artist_ids: track[:artists].pluck(:id)
        )

        tracks << refined_track
        decrease += saved_playlist.max_total_duration_ms ? refined_track[:duration_ms] : 1
        break if artist_limit <= decrease
      end
      refined_tracks << tracks
      limit -= decrease
      break if limit <= 0
    end
    refined_tracks
  end

  # アルバムのタイプがコンピレーション、または違うアーティストの曲は弾く
  def should_remove_response?(response, request_artist_id)
    response[:album][:album_type] == 'compilation' || 
    response[:artists].map { |artist| artist[:id] != request_artist_id }.all?
  end

  def limit_decrease(tracks)
    saved_playlist.max_total_duration_ms ? tracks.pluck(:duration_ms).sum : tracks.size
  end
end
