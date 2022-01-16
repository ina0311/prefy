module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  # ユーザーの情報を取得する
  def conn_request_profile(auth_params)
    request = Faraday::Connection.new("#{Constants::BASEURL}me") do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers["Authorization"] = "#{auth_params.gettoken_response[:token_type]} #{auth_params.gettoken_response[:access_token]}"
    end

    response = request.get
  end

  # ユーザーのフォローアーティストを取得する
  def conn_request_follow_artist
    follow_artist_attributes = []
    last_id = nil
    while true
      if last_id.nil?
        response = conn_request.get('me/following?type=artist&limit=50').body[:artists][:items]
      else
        response = conn_request.get("me/following?type=artist&limit=50&after=#{last_id}").body[:artists][:items]
      end
      last_id = response.last[:id]
      count = response.size

      response.each do |res|
        r = res.slice(:name).merge({ spotify_id: res[:id], image: res.dig(:images, 0, :url) })
        follow_artist_attributes << r
      end
      break if count < 50
    end
    follow_artist_attributes
  end

  # ユーザーが保存しているプレイリストを取得する
  def conn_request_saved_playlists
    saved_playlist_params = []
    offset = nil
    while true
      if offset.nil?
        response = conn_request.get('me/playlists?limit=50').body[:items]
      else
        response = conn_request.get("me/playlists?limit=50&offset=#{offset}").body[:items]
      end
      offset = response.size
      response.each do |res|
        r = res.slice(:name).merge({ spotify_id: res[:id], owner: res[:owner][:id], image: res.dig(:images, 0, :url) })
        saved_playlist_params << r
      end
      break if offset < 50
    end
    saved_playlist_params
  end

  # プレイリストを作成する
  def conn_request_playlist
    response = conn_request.post("users/#{current_user.spotify_id}/playlists") do |request|
      request.body = { name: "new playlist" }.to_json
    end
    playlist_attributes = response.body.slice(:name).merge({ spotify_id: response.body[:id], image: response.body.dig(:images, 0, :url), owner: response.body[:owner][:id] })
    playlist = Playlist.create!(playlist_attributes)
  end

  # アーティストのジャンルを取得する
  def conn_request_artist_info(artists)
    artists_info = []
    count = 0
    offset = 0
    while true
      response = conn_request.get("artists?ids=#{artists[offset, 50].join(',')}").body[:artists]
      offset += 50
      response.each do |res|
        r = res.slice(:name).merge(genres: res[:genres])
        artists_info << r
      end
      break if response.size < 50
    end
    artists_info
  end

  # 条件にそって曲を取得する
  def conn_request_search_track(match_artists, period, genres)
    tracks = []
    beginning = 0
    last = 0
    match_artists.each do |artist|
      string = "artist:#{artist} year:#{period} genre:#{genres.join(' ')}"
      query = URI.encode_www_form_component(string)
      response = conn_request.get("search?q=#{query}&type=track&limit=50").body[:tracks][:items]
      
      response.each do |res|
        r = res.slice(:name).merge({ spotify_id: res[:id], duration_ms: res[:duration_ms], album_spotify_id: res[:album][:id] })
        unless tracks[beginning..last].map { |h| h.has_value?(r[:name]) }.any?
          tracks << r
          last += 1
        end
      end
      beginning = tracks.size
    end
    tracks
  end

  # アルバムの情報を取得する
  def conn_request_album_info(ids)
    album_attributes = []
    response = conn_request("albums?ids=#{ids.join(',')}").body[:albums]
    
    response.each do |res|
      r = res.slice(:name, :release_date)merge({ spotify_id: res[:id], image: res.dig(:images, 0, :url), artist_spotify_id: res[:artists][:id] })
      album_attributes << r
    end
    album_attributes
  end

  private

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{current_user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
    end
  end
end