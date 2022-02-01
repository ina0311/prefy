module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  # ユーザーの情報を取得する
  def conn_request_profile(response)
    request = Faraday::Connection.new("#{Constants::BASEURL}me") do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers["Authorization"] = "#{response[:token_type]} #{response[:access_token]}"
    end

    request.get.body.slice(:id, :display_name, :country, :images)
  end
  
  # 制限が近いユーザーのアクセストークンを再取得する
  def conn_request_accesstoken
    body = {
      grant_type: 'refresh_token',
      refresh_token: current_user.refresh_token
    }

    request_accesstoken = Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
                            builder.response :json, parser_options: { symbolize_names: true }
                            builder.request :url_encoded
                            builder.headers["Authorization"] = "Basic #{encode_spotify_id}"
                          end

    response = request_accesstoken.post do |request|
      request.body = body
    end
    response.body.slice(:access_token, :refresh_token)
  end

  # アーティストの情報を取得する
  def conn_request_artists_info(ids)
    artist_attributes = []
    offset = 0

    while true
      response = conn_request.get("artists?ids=#{ids[offset, 50].join(',')}").body[:artists]
      response.each do |res|
        artist_attributes << res.slice(:name).merge({ spotify_id: res[:id], image: res.dig(:images, 0, :url), genres: res[:genres]})
      end
      break if artist_attributes.size == ids.size
      offset += 50
    end
    artist_attributes
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

      response.each do |res|
        r = res.slice(:name).merge({ spotify_id: res[:id], image: res.dig(:images, 0, :url), genres: res[:genres] })
        follow_artist_attributes << r
      end
      break if response.size <= 49
    end
    follow_artist_attributes
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
  def conn_request_playlist_info(playlist)
    response = conn_request.get("playlists/#{playlist.spotify_id}/tracks").body[:items]
    return unless response.present?

    response.delete_if { |res| res[:track][:id].nil? }
    artist_attributes = []
    album_attributes = []
    track_attributes = []
    artist_ids = response.map { |res| res[:track][:artists][0][:id] }
    artist_attributes = conn_request_artists_info(artist_ids.compact.uniq)

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
  def conn_request_playlist_create(name)
    response = conn_request.post("users/#{current_user.spotify_id}/playlists") do |request|
      request.body = name.present? ? { name: name }.to_json : { name: "new playlist" }.to_json
    end
    Playlist.create_by_response(response.body)
  end

  # プレイリストの曲を更新する
  def conn_request_playlist_update(tracks, playlist_id)
    query = tracks.pluck(:spotify_id).join(',spotify:track:')
    response = conn_request.put("playlists/#{playlist_id}/tracks?uris=spotify:track:#{query}")
  end

  # 条件にそって曲を取得する
  def conn_request_search_track(querys)
    tracks = []
    beginning = 0
    last = 0
    querys.each do |query|
      if query[:query].present?
        response = conn_request.get("search?q=#{query[:query]}&type=track&limit=50").body[:tracks][:items]
      else
        response = conn_request.get("search?type=track&limit=50").body[:tracks][:items]
      end

      response.each do |res|
        # TODO: コンピレーションアルバムに対応する
        next if 'compilation' == res[:album][:album_type] || query[:artist_spotify_id] != res[:artists][0][:id]
        r = res.slice(:name).merge({ 
              spotify_id: res[:id],
              duration_ms: res[:duration_ms],
              album_spotify_id: res[:album][:id],
              artist_spotify_id: res[:artists][0][:id]
            })
        # アーティストの同名曲を排除する
        case
          when !tracks[beginning..last].map { |h| h.has_value?(r[:name]) }.any?
            tracks << r
            last += 1
          when query[:artist_spotify_id].nil?
            tracks << r
            last += 1
        end
      end
      beginning = tracks.size
    end
    tracks
  end

  # アルバムの情報を取得する
  def conn_request_album_info(album_ids, artist_ids)
    album_attributes = []
    offset = 0
    response = []
    while true
      response.concat(conn_request.get("albums?ids=#{album_ids[offset, 20].join(',')}").body[:albums])
      offset += 20
      break if response.size != offset
    end

    response.zip(artist_ids).each do |res|
      r = res[0].slice(:name, :release_date).merge({
            spotify_id: res[0][:id],
            image: res[0].dig(:images, 0, :url),
            artist_spotify_id: res[1]
          })
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

  def encode_spotify_id
    Base64.urlsafe_encode64(ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID'])
  end
end