class Users::UserAccessTokenChanger < SpotifyService
  def self.call(user)
    new(user).change
  end

  def initialize(user)
    @user = user
  end

  def change
    response = conn_request_access_token(@user)
    if response.status == 200
      @user.update!(access_token: response.body[:access_token])
    end
  end
end