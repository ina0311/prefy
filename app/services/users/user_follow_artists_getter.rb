class Users::UserFollowArtistsGetter < SpotifyService
  def self.call(rspotify_user, user)
    new(rspotify_user: rspotify_user, user: user).get
  end

  def get
    response = request_follow_artist

    now_follow_artist_ids = response.map(&:id)
    default_follow_artist_ids = user.follow_artist_lists.pluck(:spotify_id)
    unfollow_artist_ids = default_follow_artist_ids - now_follow_artist_ids
    new_follow_artist_ids = now_follow_artist_ids - default_follow_artist_ids

    Artists::ArtistRegistrar.call(user, new_follow_artist_ids) if new_follow_artist_ids.present?
    FollowArtist.follow_all(new_follow_artist_ids, user) if new_follow_artist_ids.present?

    FollowArtist.unfollow_all(unfollow_artist_ids, user) if unfollow_artist_ids.present?
  end

  private

  attr_reader :rspotify_user, :user

  def request_follow_artist
    follow_artists_hashs = []
    last_id = nil
    loop do
      response = rspotify_user.following(type: 'artist', limit: 50, after: last_id)
      follow_artists_hashs.concat(response)
      break if response.size <= 49

      last_id = response.last.id
    end
    follow_artists_hashs
  end
end
