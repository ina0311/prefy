class HomeController < ApplicationController
  skip_before_action :require_login, :access_token_changed?
  def top
    reset_session
  end
end
