class ApplicationController < ActionController::Base
  include SessionsHelper
  
  before_action :require_login, :access_token_changed?

  add_flash_types :success, :secondary, :info, :warning, :danger

  def access_token_changed?
    if current_user.guest_user?
      return if (Time.now - current_user.updated_at) < 3600
      redirect_to root_path, danger: '1時間経過したのでログアウトしました'
    else
      return if (Time.now - current_user.updated_at) < 3500
      Users::UserAccessTokenChanger.call(@current_user)
    end
  end

  def current_playlist_id
    @playlist_id = session[:playlist_id]
  end

  def delete_playlist_id
    return if session[:playlist_id].nil?
    session.delete(:playlist_id)
  end
end
