class SpotifyService
  INITIAL_VALUE = 0
  INCREASE = 1
  PLUS_FIFTY = 50
  ONE_HOUR_IN_MS = 3600
  FIFTY_MIN_IN_MS = 3000

  protected

  attr_reader :user

  def initialize(**key)
    key.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def conn_request(**language)
    access_token_changed?

    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{user.access_token}"
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['Accept-Language'] = language.blank? ? 'ja;q=1' : 'en;q=1'
      builder.request :url_encoded
    end
  end

  def conn_request_token
    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.request :url_encoded
      builder.headers["Authorization"] = "Basic #{encode_spotify_id}"
      builder.headers['Accept-Language'] = 'ja;q=1'
    end
  end

  def encode_spotify_id
    Base64.urlsafe_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_SECRET_ID']}")
  end

  def access_token_changed?
    if user.guest_user?
      return if (Time.current - user.updated_at) < ONE_HOUR_IN_MS

      raise ErrorsHandler::AccessTokenExpiration
    else
      return if (Time.current - user.updated_at) < FIFTY_MIN_IN_MS

      Users::UserAccessTokenChanger.call(user)
    end
  end
end
