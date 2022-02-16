module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def request_user(user_id)
    RSpotify::User.find(user_id)
  end

  # 制限が近いユーザーのアクセストークンを再取得する
  def conn_request_access_token(user)
    body = {
      grant_type: 'refresh_token',
      refresh_token: user.refresh_token
    }

    request_access_token = Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
                            builder.response :json, parser_options: { symbolize_names: true }
                            builder.request :url_encoded
                            builder.headers["Authorization"] = "Basic #{encode_spotify_id}"
                          end

    response = request_access_token.post do |request|
      request.body = body
    end
    response.body.slice(:access_token)
  end

  # アーティストの情報を取得する
  def request_artists_info(ids)
    response = []
    offset = 0
    while true
      response.concat(RSpotify::Artist.find(ids[offset, 50]))
      break if response.size == ids.size
      offset += 50
    end
    response
  end

  # ユーザーのフォローアーティストを取得する
  def request_follow_artist(user)
    follow_artists_hashs = []
    last_id = nil
    while true
      response = user.following(type: 'artist', limit: 50, after: last_id)
      follow_artists_hashs.concat(response)
      break if response.size <= 49
      last_id = response.last.id
    end
    follow_artists_hashs
  end

  # ユーザーが保存しているプレイリストを取得する
  def request_saved_playlists(user)
    @user = user
    playlists = []
    offset = 0
    while true
      response = conn_request.get("users/#{@user.spotify_id}/playlists?limit=50&offset=#{offset}").body[:items]
      playlists.concat(response)
      break if response.size <= 49
      offset += 50
    end
    playlists
  end

  # プレイリストを取得する
  def request_get_playlist(playlist_id)
    RSpotify::Playlist.find_by_id(playlist_id)
  end

  # プレイリストを作成する
  def request_create_playlist(user, name)
    @user = user
    response = conn_request.post("users/#{@user.spotify_id}/playlists") do |req|
      req.body = name.present? ? { name: name }.to_json : { name: "new playlist" }.to_json
    end
  end

  # プレイリストの曲を更新する
  def request_playlist_tracks_update(user, playlist_id, query)
    @user = user
    conn_request.put("playlists/#{playlist_id}/tracks?uris=spotify:track:#{query}").status
  end

  # 曲を取得する
  def request_get_tracks(track_ids)
    RSpotify::Track.find(track_ids)
  end
  
  # 条件にそって曲を取得する
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

  # アルバムの情報を取得する
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

  private

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{@user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
    end
  end

  def encode_spotify_id
    Base64.urlsafe_encode64(ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID'])
  end
end