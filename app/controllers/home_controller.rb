class HomeController < ApplicationController
  skip_before_action :require_login
  layout 'home'
  def top
    session.delete(:user_id)
  end
end
