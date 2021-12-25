class HomeController < ApplicationController
  skip_before_action :require_login, :current_user
  def top; end
end
