class SpotifyGuestLogin < SpotifyService
  def self.call
    new.guest_login
  end

  def guest_login
    request_guest_login
  end

  private

  def request_guest_login
    conn_request_token.post { |req| req.body = { grant_type: 'client_credentials' } }
  end
end
