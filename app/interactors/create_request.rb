class CreateRequest
  include Interactor

  def call
    query_params = {
        client_id: ENV['SPOTIFY_CLIENT_ID'],
        response_type: 'code',
        redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
        code_challenge_method: 'S256',
        code_challenge: context.code_challenge,
        state: SecureRandom.base64(16),
        scope: Constants::AUTHORIZATIONSCOPES
      }
      context.query_params = query_params
  end
end