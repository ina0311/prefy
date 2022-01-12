class FollowArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }

  def self.list_update(params, user)
    default_follow_artist_ids = user.follow_artist_lists.pluck(:spotify_id)
    now_follow_artist_ids = params.pluck(:id)
    unfollow_artists_ids = default_follow_artist_ids - now_follow_artist_ids
    new_follow_artist_ids = now_follow_artist_ids - default_follow_artist_ids

    Artist.all_update(params)

    FollowArtist.unfollow_all(unfollow_artist_ids, user) if unfollow_artists_ids.present?
    FollowArtist.follow_all(new_follow_artists, user) if new_follow_artist_ids.present?
  end

  def self.follow(artist, user)
    follow_artist = user.follow_artists.create(artist_id: artist.id) 
  end

  def self.unfollow_all(unfollow_artist_ids, user)
    unfollow_artists = Artist.where(spotify_id: unfollow_artist_ids).ids
    FollowArtist.transaction do
      user.follow_artists.where(artist_id: unfollow_artists).destroy_all
    end
  end

  def self.follow_all(new_follow_artist_ids, user)
    follow_artists = Artist.where(spotify_id: new_follow_artist_ids).ids
    # ここでは新しくフォローしたアーティストしかいないのでinsert_all
    follow_artist_attributes = follow_artists.map do |id| 
                                {user_id: user.id, artist_id: id, created_at: Time.current, updated_at: Time.current}
                              end
    FollowArtist.insert_all(follow_artist_attributes)
  end
end
