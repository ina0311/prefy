class ApplicationController < ActionController::Base
  include SessionsHelper
  include ErrorsHandler
  
  before_action :require_login

  add_flash_types :success, :secondary, :info, :warning, :danger

  def current_playlist_id
    @playlist_id = session[:playlist_id]
  end

  def delete_playlist_id
    return if session[:playlist_id].nil?
    session.delete(:playlist_id)
  end

  def js_format_flash_message(type, message)
    respond_to do |format|
      format.js { flash.now[type] = message }
    end
  end
end
