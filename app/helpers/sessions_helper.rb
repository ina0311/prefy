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

  def login(user_attributes)
    user = User.find_or_initialize_by(spotify_id: user_attributes[:id])
    user.update!(
      name: user_attributes[:display_name],
      image: user_attributes.dig(:images, 0, :url),
      country: user_attributes[:country],
      access_token: user_attributes[:access_token],
      refresh_token: user_attributes[:refresh_token]
    )
    session[:user_id] = user.id
  end

  def logout
    session.delete(:user_id)
  end
end