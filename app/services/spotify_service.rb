class SpotifyService
  include RequestUrl

  def guest_user?(user)
    user.spotify_id == 'guest_user'
  end
end