class HomeController < ApplicationController
  skip_before_action :require_login, :current_user, :access_token_changed?
  def top; end
end
