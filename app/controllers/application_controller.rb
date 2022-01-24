class ApplicationController < ActionController::Base
  include SessionsHelper
  include RequestUrl

  before_action :current_user, :require_login, :access_token_changed?

  add_flash_types :success, :info, :warning, :danger

  def access_token_expired?
    (Time.now - current_user.updated_at) > 3300
  end

  def access_token_changed?
    if access_token_expired?
      response = conn_request_accesstoken
      @current_user.update!(access_token: response[:access_token], refresh_token: response[:refresh_token])
    end
  end
end
