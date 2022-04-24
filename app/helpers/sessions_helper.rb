module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def logged_in?
    !!session[:user_id]
  end

  def require_login
    redirect_to root_path unless logged_in?
  end

  def player_status
    session[:player]
  end

  def now_playing?
    !!session[:playing]
  end
  
  def current_track
    return if session[:track_id].nil?
    Track.includes(album: :artists).find(session[:track_id])
  end
end
