class Api::V1::AuthController < ApplicationController
  require 'securerandom'
  require 'openssl'

  def authorize
    session[:code_verifier] = SecureRandom.alphanumeric(64)
    code_challenge = Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(session[:code_verifier]), padding: false)
    query_params = {
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      response_type: 'code',
      redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
      code_challenge_method: 'S256',
      code_challenge: code_challenge,
      state: SecureRandom.base64(16),
      scope: Constants::AUTHORIZATIONSCOPES,
      show_dialog: true
    }
    response = conn_auth.get("?#{query_params.to_query}")
    redirect_to "#{response[:location]}"
  end

  private

  def conn_auth
    Faraday::Connection.new(Constants::AUTHORIZATIONURL) do |builder|
      builder.response :logger
      builder.request :url_encoded
    end
  end
end
