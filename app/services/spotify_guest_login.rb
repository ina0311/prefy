class SpotifyGuestLogin < SpotifyService
  def self.call
    new.guest_login
  end

  def guest_login
    response = request_guest_login
    user = User.find('guest_user')
    user.update!(access_token: response.body[:access_token])
    user
  end

  private

  def request_guest_login
    conn_request_token.post { |req| req.body = { grant_type: 'client_credentials' } }
  end
end
