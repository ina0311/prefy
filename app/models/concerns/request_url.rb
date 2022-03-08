module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def request_user(user_id)
    RSpotify::User.find(user_id)
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

  # アーティストをフォローする
  def request_artist_follow(user, artist_id)
    @user = user
    conn_request.put("me/following?type=artist&ids=#{artist_id}").status
  end

  def request_artist_unfollow(user, artist_id)
    @user = user
    conn_request.delete("me/following?type=artist&ids=#{artist_id}").status
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

  # プレイリストに曲を追加する
  def request_playlist_add_track(user, playlist_id, query)
    @user = user
    conn_request.post("playlists/#{playlist_id}/tracks?uris=spotify:track:#{query}").status
  end

  # プレイリストの曲を更新する
  def request_playlist_tracks_update(user, playlist_id, query)
    @user = user
    conn_request.put("playlists/#{playlist_id}/tracks?uris=spotify:track:#{query}").status
  end

  # プレイリストの極を削除する
  def request_remove_playlist_tracks(user, playlist_id, request_bodys)
    @user = user
    if request_bodys.class == 'Array'
      request_bodys.each do |request_body|
        response = conn_request.delete("playlists/#{playlist_id}/tracks") do |req|
                    req.body = request_body.to_json
                  end
        break if response.status != 200
        return 200
      end
    else
      response = conn_request.delete("playlists/#{playlist_id}/tracks") do |req|
                  req.body = request_bodys.to_json
                 end
      return response.status
    end
  end

  # 曲を取得する
  def request_get_tracks(track_ids)
    offset = 0
    if track_ids.class == 'Array'
      response = []
      while true
        response.concat(RSpotify::Track.find(track_ids[offset, 50]))
        break if response.size == track_ids.size
        offset += 50
      end
      response
    else
      RSpotify::Track.find(track_ids)
    end
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

  # 検索する
  def request_search(word, type)
    response = RSpotify::Base.search(word, type)
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

  # 制限が近いユーザーのアクセストークンを再取得する
  def conn_request_access_token(user)
    binding.pry
    body = {
      grant_type: 'refresh_token',
      refresh_token: user.refresh_token
    }

    conn_request_token.post do |request|
      request.body = body
    end
  end

  # ゲストユーザーログイン
  def request_guest_login
    conn_request_token.post { |req| req.body = {grant_type: 'client_credentials'} }
  end

  private

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{@user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
    end
  end

  def conn_request_token
    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.request :url_encoded
      builder.headers["Authorization"] = "Basic #{encode_spotify_id}"
    end
  end

  def encode_spotify_id
    Base64.urlsafe_encode64(ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID'])
  end
end