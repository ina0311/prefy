class RequestToken
  include Interactor

  def call
    begin
      response = conn_request_token.post do |request|
        request.headers["Authorization"] = "Basic #{create_basictoken}"
        request.body = context.body
      end

      context.gettoken_response = response.body
    rescue
      context.message = 'request token error'
    end
  end

  def conn_request_token
    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.request :url_encoded
    end
  end

  def create_basictoken
    Base64.urlsafe_encode64(Constants::AUTHORIZATIONSTRING)
  end
end