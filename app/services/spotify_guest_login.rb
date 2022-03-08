class SpotifyGuestLogin < SpotifyService
  def self.call
    new.guest_login
  end

  def guest_login
    request_guest_login
  end
end