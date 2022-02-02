class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_login, :access_token_changed?, :current_user
  def authorize
    response = AuthorizationSpotify.call(code_challenge: create_codechallenge)

    redirect_to "#{response[:location]}"
  end

  def callback
    if params[:error]
      redirect_to root_path, danger: '認可されませんでした'
    else
      get_token_response = GetToken.call(code: params[:code], code_verifier: find_codeverifier)

      profile_response = conn_request_profile(get_token_response)
      user_attributes = profile_response.merge(
                          access_token: get_token_response[:access_token],
                          refresh_token: get_token_response[:refresh_token]
                        )
      
      login(user_attributes)

      follow_artist_attributes = conn_request_follow_artist
      FollowArtist.list_update(follow_artist_attributes, current_user)

      redirect_to api_v1_saved_playlists_path, success: "ログインしました"
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  private

  def create_codechallenge
    # code_verifierの作成
    session[:code_verifier] = SecureRandom.alphanumeric(64)
    # code_challengeの作成
    Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(session[:code_verifier]), padding: false)
  end

  def find_codeverifier
    code_verifier = session[:code_verifier]
    session.delete(:code_verifier)

    code_verifier
  end
end
