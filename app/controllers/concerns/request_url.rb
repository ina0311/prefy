module RequestUrl
  extend ActiveSupport::Concern
  include SessionsHelper

  def conn_request
    Faraday::Connection.new(Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.headers['Authorization'] = "Bearer #{current_user.access_token}"
      builder.headers['Content-Type'] = 'application/qjson'
    end
  end
end