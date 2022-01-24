class RequestToken
  include Interactor

def call
    response = conn_request_token.post do |request|
      request.headers["Authorization"] = "Basic #{create_basictoken}"
      request.body = context.body
    end

    context.token_type = response.body[:token_type]
    context.access_token = response.body[:access_token]
    context.refresh_token = response.body[:refresh_token]
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