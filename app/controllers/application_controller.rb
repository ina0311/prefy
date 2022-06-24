class ApplicationController < ActionController::Base
  include SessionsHelper
  include ErrorsHandler

  before_action :require_login

  add_flash_types :success, :secondary, :info, :warning, :danger

  def js_format_flash_message(type, message)
    respond_to do |format|
      format.js { flash.now[type] = message }
    end
  end
end
