class Users::FollowArtistUnfollower < SpotifyService
  def self.call(user, follow_artist)
    new(user, follow_artist).unfollow
  end

  def initialize(user, follow_artist)
    @user = user
    @follow_artist = follow_artist
  end

  def unfollow
    if user.guest_user?
      follow_artist.destroy!
    else
      response = request_artist_unfollow
      if response == 204
        follow_artist.destroy!
      end
    end
  end

  private

  attr_reader :user, :follow_artist

  def request_artist_unfollow
    conn_request.delete("me/following?type=artist&ids=#{follow_artist.artist_id}").status
  end
end