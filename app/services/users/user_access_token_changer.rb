class Users::UserAccessTokenChanger < SpotifyService
  def self.call(user)
    new(user).change
  end

  def initialize(user)
    @user = user
  end

  def change
    response = conn_request_access_token
    if response.status == 200
      @user.update!(access_token: response.body[:access_token])
    end
  end

  private

  def conn_request_access_token
    body = {
      grant_type: 'refresh_token',
      refresh_token: @user.refresh_token
    }

    conn_request_token.post do |request|
      request.body = body
    end
  end
end