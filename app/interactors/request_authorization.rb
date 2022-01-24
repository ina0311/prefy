class RequestAuthorization < AuthorizationSpotify
  include Interactor

  def call
    response = conn_auth.get("?#{context.query_params.to_query}")
    context.location = response[:location]
  end

  def conn_auth
    Faraday::Connection.new(Constants::AUTHORIZATIONURL)
  end
end