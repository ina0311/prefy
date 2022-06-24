class SavedPlaylists::BasedOnSavedPlaylistTracksGetter < SpotifyService
  # saved_playlistの情報からクエリを作成、曲を取得、絞り込み
  def self.call(saved_playlist, user)
    new(saved_playlist: saved_playlist, user: user).get
  end

  def get
    year = saved_playlist.convert_year
    if saved_playlist.only_follow_artist
      artist_ids = saved_playlist.call_artist_ids
      ramdom_tracks = search_tracks(artist_ids, year).flatten
    end

    if saved_playlist.include_artists.present?
      target_ids = saved_playlist.include_artists.ids
      target_tracks = search_tracks(target_ids, year)
    end

    return false if ramdom_tracks.blank? && target_tracks.blank?

    saved_playlist.refine_tracks(ramdom_tracks, target_tracks)
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
    loop do
      response.concat(RSpotify::Artist.find(ids[offset, 50]))
      break if ids.size == response.size

      offset += PLUS_FIFTY
    end

    response.map do |res|
      string = "artist:#{res.name}"
      string += year if year
      { id: res.id, params: URI.encode_www_form_component(string) }
    end
  end

  def request_search_tracks(request_params)
    tracks = request_params.map do |req|
      response = conn_request.get("search?q=#{req[:params]}&type=track&limit=50").body[:tracks][:items]
      next if response.blank?

      artist_tracks = response.map do |res|
        next nil if should_remove_response?(res, req[:id])

        Track.new(
          spotify_id: res[:id],
          name: res[:name],
          duration_ms: res[:duration_ms],
          position: res[:traci_number],
          artist_ids: res[:artists].pluck(:id)
        )
      end
      artist_tracks.compact.uniq { |track| track[:name] }
    end
    tracks.reject!(&:blank?)
    tracks
  end

  # アルバムのタイプがコンピレーション、または違うアーティストの曲は弾く
  def should_remove_response?(response, request_artist_id)
    if response[:album][:album_type] == 'compilation'
      true
    elsif response[:artists].map { |artist| artist[:id] != request_artist_id }.all?
      true
    else
      false
    end
  end
end
