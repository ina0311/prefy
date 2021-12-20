class Api::V1::SessionsController < ApplicationController
  def callback
    if params[:error]
      redirect_to root_path
    else
      code_verifier = session[:code_verifier]
      session.delete(:code_verifier)
      body = {
        grant_type: 'authorization_code',
        code: params[:code],
        redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
        client_id: ENV['SPOTIFY_CLIENT_ID'],
        code_verifier: code_verifier
      }

      auth_response = conn_request_token.post do |request|
        basic_token = Base64.urlsafe_encode64(Constants::AUTHORIZATIONSTRING)
        request.headers["Authorization"] = "Basic #{basic_token}"
        request.body = body
      end

      auth_params = auth_response.body

      profile_response = conn_request.get('me') do |request|
        request.headers["Authorization"] = "#{auth_params[:token_type]} #{auth_params[:access_token]}"
      end

      user_params = profile_response.body.merge(auth_params)
      
      @user = User.find_or_create_by()
    end
  end

  private

  def conn_request_token
    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.request :url_encoded
    end
  end

  def conn_request
    Faraday::Connection.new(url: Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
    end
  end
end
