class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :current_user
  before_action :require_login
end
