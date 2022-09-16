class ApplicationController < ActionController::Base
  include SessionsHelper
  include ErrorsHandler

  before_action :require_login

  add_flash_types :success, :secondary, :info, :warning, :danger
  unless Rails.env.development?
    rescue_from Exception, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :render_404
  end

  def js_format_flash_message(type, message)
    respond_to do |format|
      format.js { flash.now[type] = message }
    end
  end

  def render_500(e)
    logger.error [e, *e.backtrace].join("\n")
    render 'errors/500', status: 500
  end

  def render_404
    render 'errors/404', status: 404
  end
end
