class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :require_login, :access_token_changed?, only: %i(create failure guest_login)

  def create
    rspotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    user = User.find_or_create_from_rspotify!(rspotify_user)
    session[:user_id] = user[:spotify_id]
    
    Users::UserFollowArtistsGetter.call(rspotify_user, user)
    redirect_to api_v1_saved_playlists_path, success: "ログインしました"
  end

  def destroy
    reset_session
    redirect_to root_path, danger: "ログアウトしました"
  end

  def guest_login
    response = SpotifyGuestLogin.call
    if response.status == 200
      user = User.find('guest_user')
      user.update!(access_token: response.body[:access_token])
      session[:user_id] = user[:spotify_id]
    end
    redirect_to api_v1_saved_playlists_path, success: "ゲストユーザーとしてログインしました"
  end

  def failure
    redirect_to root_url, alert: "Authentication failed."
  end
end
