class Users::ArtistFollower < SpotifyService
  def self.call(user, artist_id)
    new(user: user, artist_id: artist_id).follow
  end

  def follow
    if user.guest_user?
      create_follow_artist!
    else
      response = request_artist_follow
      if response == 204
        create_follow_artist!
      end
    end
  end

  private

  attr_reader :user, :artist_id

  def create_follow_artist!
    Artists::ArtistRegistrar.call(user, [artist_id]) unless Artist.find_by(spotify_id: artist_id)
    FollowArtist.create!(user_id: user.spotify_id, artist_id: artist_id)
  end

  def request_artist_follow
    conn_request.put("me/following?type=artist&ids=#{artist_id}").status
  end
end
