class Users::UserAccessTokenChanger < SpotifyService
  def self.call(user)
    new(user: user).change
  end

  def change
    response = conn_request_access_token
    return false unless response.success?

    user.update!(access_token: response.body[:access_token])
  end

  private

  attr_reader :user

  def conn_request_access_token
    body = {
      grant_type: 'refresh_token',
      refresh_token: user.refresh_token
    }

    conn_request_token.post do |request|
      request.body = body
    end
  end
end
