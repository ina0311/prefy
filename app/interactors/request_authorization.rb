class RequestAuthorization < AuthorizationSpotify
  include Interactor

  def call
    begin
      response = conn_auth.get("?#{context.query_params.to_query}")
      context.location = response[:location]
    rescue
      context.fail!(message: "authenticate_user.failure")
    end
  end

  def conn_auth
    Faraday::Connection.new(Constants::AUTHORIZATIONURL) do |builder|
      builder.response :logger
      builder.request :url_encoded
    end
  end
end