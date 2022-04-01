class Users::UserFollowArtistsGetter < SpotifyService
  def self.call(rspotify_user, user)
    new(rspotify_user, user).get
  end
  
  def initialize(rspotify_user, user)
    @rspotify_user = rspotify_user
    @user = user
  end

  def get
    response = request_follow_artist

    now_follow_artists = response.map(&:id)
    default_follow_artists = user.follow_artist_lists.pluck(:spotify_id)
    unfollow_artists = default_follow_artists - now_follow_artists
    new_follow_artists = now_follow_artists - default_follow_artists

    Artists::ArtistRegistrar.call(user, new_follow_artists) if new_follow_artists.present?
    FollowArtist.follow_all(new_follow_artists, user) if new_follow_artists.present?

    FollowArtist.unfollow_all(unfollow_artists, user) if unfollow_artists.present?
  end

  private

  attr_reader :rspotify_user, :user

  def request_follow_artist
    follow_artists_hashs = []
    last_id = nil
    while true
      response = rspotify_user.following(type: 'artist', limit: 50, after: last_id)
      follow_artists_hashs.concat(response)
      break if response.size <= 49
      last_id = response.last.id
    end
    follow_artists_hashs
  end
end