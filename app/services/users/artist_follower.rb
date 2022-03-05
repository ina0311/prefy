class Users::ArtistFollower < SpotifyService
  def self.call(user, artist_id)
    new(user, artist_id).follow
  end
  
  def initialize(user, artist_id)
    @user = user
    @artist_id = artist_id
  end

  def follow
    response = request_artist_follow(@user, @artist_id)
    if response == 204
      Artists::ArtistRegistrar.call([@artist_id]) unless Artist.find_by(spotify_id: @artist_id)
      FollowArtist.create!(user_id: @user.spotify_id, artist_id: @artist_id)
    end
  end
end