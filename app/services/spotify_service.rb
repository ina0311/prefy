class SpotifyService

  protected

  attr_reader :user

  def conn_request
    access_token_changed?

    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{user.access_token}"
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

  def access_token_changed?
    if user.guest_user?
      return if (Time.now - user.updated_at) < 3600
      redirect_to root_path, danger: '1時間経過したのでログアウトしました'
    else
      return if (Time.now - user.updated_at) < 3500
      Users::UserAccessTokenChanger.call(user)
    end
  end
end