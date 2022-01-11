class ApplicationController < ActionController::Base
  include SessionsHelper
  include RequestUrl

  before_action :current_user
  before_action :require_login
end
