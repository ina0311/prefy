class Api::V1::SessionsController < ApplicationController
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
      
      binding.pry
      
      @user = User.find_or_create_by(name: user_params[:display_name],
                                     image: user_params[:image],
                                     country: user_params[:country],
                                     spotify_id: user_params[:id])
      @user.update!(access_token: user_params[:access_token], refresh_token: user_params[:refresh_token])
      
    end
  end
end
