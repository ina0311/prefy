class FollowArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }

  def self.list_update(params, user)
    default_follow_artist_ids = user.follow_artist_lists.pluck(:spotify_id)
    now_follow_artist_ids = params.pluck(:id)
    new_follow_artist_ids = now_follow_artist_ids - default_follow_artist_ids

    unfollow_artists_ids = default_follow_artist_ids - now_follow_artist_ids
    FollowArtist.unfollow(unfollow_artists_ids, user) if unfollow_artists_ids.present?

    Artist.all_update(params)

    binding.pry
    FollowArtist.all_follow(new_follow_artist_ids, user)
    binding.pry
  end

  def self.follow(artist, user)
    follow_artist = user.follow_artists.create(artist_id: artist.id) 
  end

  def self.unfollow(unfollow_artists, user)
    unfollow_artists.each { |id| user.follow_artist_lists.delete(spotify_id: id) }
  end

  def self.all_follow(follow_artist_ids, user)
    follow_artist_attributes = follow_artist_ids.map { |id| {user_id: user.id, artist_id: id} }
    
    binding.pry
    
    FollowArtist.insert_all(follow_artist_attributes, record_timestamps: true)
  end
end
