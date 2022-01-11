class User < ApplicationRecord
  attr_encrypted :access_token, key: ENV['TOKEN_ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['TOKEN_ENCRYPTION_KEY']

  has_many :saved_playlists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy
  has_many :follow_artist_lists, through: :follow_artists, source: :artist

  validates :name, presence: true
  validates :country, presence: true
  validates :spotify_id, presence: true

  def access_token_expired?
    (Time.now - self.updated_at) > 3300
  end

  def self.refresh_token
    if current_user.access_token_expired?

      response = conn_request_refreshtoken.post
      current_user.update(access_token: auth_params[:access_token])
    else
      root_path
    end
  end

  private

  def conn_request_refreshtoken
    body = {
      grant_type: 'refresh_token',
      refresh_token: current_user.refresh_token,
    }

    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.require :url_encoded
      builder.headers["Authorization"] = "Basic #{encode_spotify_id}"
      request.body = body
    end
  end

  def encode_spotify_id
    Base64.urlsafe_encode64(ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID'])
  end
end
