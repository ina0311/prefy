class Users::UserFollowArtistsGetter < SpotifyService
  def self.call(rspotify_user, user)
    new(rspotify_user, user).get
  end
  
  def initialize(rspotify_user, user)
    @rspotify_user = rspotify_user
    @user = user
  end

  def get
    response = request_follow_artist(@rspotify_user)
    now_follow_artists = response.map(&:id)

    Artists::ArtistRegistrar.call(now_follow_artists)

    default_follow_artists = @user.follow_artist_lists.pluck(:spotify_id)
    unfollow_artists = default_follow_artists - now_follow_artists
    new_follow_artists = now_follow_artists - default_follow_artists

    FollowArtist.unfollow_all(unfollow_artists, @user) if unfollow_artists.present?
    FollowArtist.follow_all(new_follow_artists, @user) if new_follow_artists.present?
  end
end