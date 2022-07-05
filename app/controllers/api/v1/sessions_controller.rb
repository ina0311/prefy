class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_login

  def create
    user = User.find_or_create_from_omniauth!(request.env['omniauth.auth'])
    session[:user_id] = user[:spotify_id]
    Users::UserFollowArtistsGetter.call(user)
    redirect_to api_v1_saved_playlists_path, success: t(".success")
  end

  def destroy
    reset_session
    redirect_to root_path, danger: t(".success")
  end

  def guest_login
    guest_user = SpotifyGuestLogin.call
    session[:user_id] = guest_user[:spotify_id]
    redirect_to api_v1_saved_playlists_path, success: t(".success")
  end

  def failure
    redirect_to root_url, danger: t(".fail")
  end
end
