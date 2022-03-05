class Users::FollowArtistUnfollower < SpotifyService
  def self.call(user, follow_artist)
    new(user, follow_artist).unfollow
  end

  def initialize(user, follow_artist)
    @user = user
    @follow_artist = follow_artist
  end

  def unfollow
    response = request_artist_unfollow(@user, @follow_artist.artist_id)
    if response == 204
      @follow_artist.destroy!
    end
  end
end