class Api::V1::SessionsController < ApplicationController
  def authorize
    response = AuthorizationSpotify.call(code_challenge: create_codechallenge)

    redirect_to "#{response[:location]}"
  end

  def callback
    if params[:error]
      redirect_to root_path
    else
      code_verifier = session[:code_verifier]
      session.delete(:code_verifier)

      auth_params = GetToken.call(code: params[:code], code_verifier: code_verifier)

      profile_response = conn_request.get('me') do |request|
        request.headers["Authorization"] = "#{auth_params.gettoken_response[:token_type]} #{auth_params.gettoken_response[:access_token]}"
      end

      user_params = profile_response.body.merge(auth_params.gettoken_response)
  
      @user = User.find_or_create_by(name: user_params[:display_name],
                                     image: user_params[:image],
                                     country: user_params[:country],
                                     spotify_id: user_params[:id])

      @user.update(access_token: user_params[:access_token], refresh_token: user_params[:refresh_token])
      
      session[:user_id] = @user.id
      redirect_to api_v1_playlists_path
    end
  end

  private

  def create_codechallenge
    # code_verifierの作成
    session[:code_verifier] = SecureRandom.alphanumeric(64)
    # code_challengeの作成
    Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(session[:code_verifier]), padding: false)
  end

  def conn_request
    Faraday::Connection.new(url: Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
    end
  end
end
