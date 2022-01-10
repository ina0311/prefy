module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{current_user.access_token}"
      builder.headers['Content-Type'] = 'application/qjson'
    end
  end

  def conn_request_playlist
    response = conn_request.post("users/#{current_user.spotify_id}/playlists") do |request|
      request.body = { name: "new playlist" }.to_json
    end
    playlist_attributes = response.body.slice(:name).merge({ spotify_id: response.body.dig(:id), image: response.body.dig(:images, 0, :url), owner: response.body.dig(:owner, :id) })
    playlist = Playlist.create(playlist_attributes)
  end
end