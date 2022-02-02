class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_login, :access_token_changed?, :current_user
  skip_before_action :verify_authenticity_token, only: :create

  def create
    user = User.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
    session[:user_id] = user[:spotify_id]

    follow_artist_attributes = conn_request_follow_artist
    FollowArtist.list_update(follow_artist_attributes, user)
    redirect_to api_v1_saved_playlists_path, success: "ログインしました"
  end

  def destroy
    logout
    redirect_to root_path
  end

  def failure
    redirect_to root_url, alert: "Authentication failed."
  end
end
