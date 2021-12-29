module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def logged_in?
    @current_user.present?
  end

  def require_login
    redirect_to root_path unless logged_in?
  end

  def login(user_params)
    user = User.find_or_create_by(spotify_id: user_params[:id]) do |user|
      user.name = user_params[:display_name]
      user.image = user_params[:image]
      user.country = user_params[:country]
    end

    user.update(access_token: user_params[:access_token], refresh_token: user_params[:refresh_token])
    session[:user_id] = user.id
  end

  def logout
    session.delete(:user_id)
  end
end