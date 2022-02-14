module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def request_find_user(user_id)
    
    binding.pry
    
    RSpotify::User.find(user_id)
  end
  # 制限が近いユーザーのアクセストークンを再取得する
  def conn_request_access_token
    body = {
      grant_type: 'refresh_token',
      refresh_token: current_user.refresh_token
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
  def conn_request_saved_playlists
    saved_playlist_params = []
    offset = 0
    while true
      if offset.zero?
        response = conn_request.get('me/playlists?limit=50').body[:items]
      else
        response = conn_request.get("me/playlists?limit=50&offset=#{offset}").body[:items]
      end

      response.each do |res|
        r = res.slice(:name).merge({ spotify_id: res[:id], owner: res[:owner][:id], image: res.dig(:images, 0, :url) })
        saved_playlist_params << r
      end
      break if response.size <= 49
      offset += 50
    end
    saved_playlist_params
  end

  # プレイリストの情報を取得する
  def request_playlist_info(playlist)
    response = conn_request.get("playlists/#{playlist.spotify_id}/tracks").body[:items]
    return unless response.present?

    response.delete_if { |res| res[:track][:id].nil? }
    artist_attributes = []
    album_attributes = []
    track_attributes = []
    artist_ids = response.map { |res| res[:track][:artists][0][:id] }
    artist_attributes = request_artists_info(artist_ids.compact.uniq)

    response.each do |res|
      album = res[:track][:album].slice(:name).merge({
                spotify_id: res[:track][:album][:id],
                image: res.dig(:track, :album, :images, 0, :url),
                release_date: res[:track][:album][:release_date],
                artist_spotify_id: res[:track][:artists][0][:id]
              })
      album_attributes.push(album) unless album_attributes.include?(album)
    end

    response.each do |res|
      next if res[:track][:id].nil?
      track = res[:track].slice(:name).merge({
                spotify_id: res[:track][:id],
                duration_ms: res[:track][:duration_ms],
                album_spotify_id: res[:track][:album][:id]
              })
      track_attributes.push(track)
    end

    return { artists: artist_attributes, albums: album_attributes, tracks: track_attributes }
  end

  # プレイリストを作成する
  def request_create_playlist(user, name)
    
    binding.pry
    
    user.create_playlist!(name)
  end

  # プレイリストを取得する
  def request_find_playlist(playlist_id)
    RSpotify::Playlist.find_by_id(playlist_id)
  end

  # プレイリストの曲を更新する
  def request_playlist_tracks_update(playlist, track_ids)
    
    binding.pry
    
    playlist.add_tracks!(track_ids)
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
      builder.headers['Authorization'] = "Bearer #{current_user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
    end
  end

  def encode_spotify_id
    Base64.urlsafe_encode64(ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID'])
  end
end