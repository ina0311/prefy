class Api::V1::AuthController < ApplicationController
  require 'securerandom'
  require 'base64'

  def authorize
    url = "https://accounts.spotify.com/authorize"
    query_params = {
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      response_type: 'code',
      redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
      state: SecureRandom.base64(16),
      scope: Constants::AUTHORIZATIONSCOPES,
      show_dialog: true
    }
    redirect_to "#{url}?#{query_params.to_query}"
  end

  def callback
    if params[:error]
      redirecto_to root_path
    else
      headers = {
        Authorization: 'Basic ' + Base64.encode64(Constants::AUTHORIZATIONSTRING),
        Content_Type: 'application/x-www-form-urlencoded'
      },
      body = {
        grant_type: 'authorization_code',
        code: params[:code],
        redirect_uri: ENV['SPOTIFY_REDIRECT_URI']
      }
    end
  end
end
