class HomeController < ApplicationController
  skip_before_action :require_login, :access_token_changed?
  layout 'home'
  def top
    session.delete(:user_id)
  end
end
