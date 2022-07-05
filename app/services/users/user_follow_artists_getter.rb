class Users::UserFollowArtistsGetter < SpotifyService
  def self.call(user)
    new(user: user).get
  end

  def get
    response = request_follow_artists
    now_follow_artist_ids = response.map { |artist| artist[:id] }
    default_follow_artist_ids = user.follow_artist_lists.pluck(:spotify_id)
    unfollow_artist_ids = default_follow_artist_ids - now_follow_artist_ids
    new_follow_artist_ids = now_follow_artist_ids - default_follow_artist_ids
    if new_follow_artist_ids.present?
      Artists::ArtistRegistrar.call(user, new_follow_artist_ids)
      FollowArtist.follow_all(new_follow_artist_ids, user)
    end
    FollowArtist.unfollow_all(unfollow_artist_ids, user) if unfollow_artist_ids.present?
  end

  private

  attr_reader :user

  def request_follow_artists
    follow_artists = []
    last_id = nil
    loop do
      response = conn_request.get("me/following?type=artist&limit=50#{after_last_id(last_id)}").body[:artists][:items]
      follow_artists.concat(response)
      break if response.size < 50

      last_id = response.last[:id]
    end
    follow_artists
  end

  def after_last_id(last_id)
    last_id.nil? ? '' : "&after=#{last_id}"
  end
end
