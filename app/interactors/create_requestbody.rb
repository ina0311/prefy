class CreateRequestbody
  include Interactor

  def call
    begin
      body = {
        grant_type: 'authorization_code',
        code: context.code,
        redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
        client_id: ENV['SPOTIFY_CLIENT_ID'],
        code_verifier: context.code_verifier
      }

      context.body = body
    rescue
      context.fail!(message: "create body error")
    end
  end
end