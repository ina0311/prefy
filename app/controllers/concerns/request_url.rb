module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{current_user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
    end
  end

  def conn_request_profile(auth_params)
    request = Faraday::Connection.new("#{Constants::BASEURL}me") do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers["Authorization"] = "#{auth_params.gettoken_response[:token_type]} #{auth_params.gettoken_response[:access_token]}"
    end

    response = request.get
  end

  def conn_request_follow_artist
    follow_artist_params = []
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
        r = res.slice(:id, :name, :images)
        follow_artist_params << r
      end
      break if count < 50
    end
    follow_artist_params
  end

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

  def conn_request_playlist
    response = conn_request.post("users/#{current_user.spotify_id}/playlists") do |request|
      request.body = { name: "new playlist" }.to_json
    end
    playlist_attributes = response.body.slice(:name).merge({ spotify_id: response.body[:id], image: response.body.dig(:images, 0, :url), owner: response.body[:owner][:id] })
    playlist = Playlist.create!(playlist_attributes)
  end
end