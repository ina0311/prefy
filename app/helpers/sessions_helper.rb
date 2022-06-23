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

  def current_playlist
    @current_playlist ||= session[:playlist_id]
  end

  def delete_current_playlist
    return if session[:playlist_id].nil?

    session.delete(:playlist_id)
  end
end
