class ApplicationController < ActionController::Base
  include SessionsHelper
  include RequestUrl

  before_action :require_login, :access_token_changed?

  add_flash_types :success, :secondary, :info, :warning, :danger
  
  def access_token_expired?
    (Time.now - current_user.updated_at) > 3300
  end

  def access_token_changed?
    if access_token_expired?
      response = conn_request_access_token(current_user)
      @current_user.update!(access_token: response[:access_token])
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
