class FollowArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }

  scope :genres_id_order_desc, -> { joins(artist: [artist_genres: :genre]).group("genres.id").having('count(*) >= ?', 5).order("count_all DESC").count }

  def self.unfollow_all(unfollow_artists, user)
    FollowArtist.transaction do
      user.follow_artists.where(artist_id: unfollow_artists).destroy_all
    end
  end

  def self.follow_all(new_follow_artists, user)
    follow_artists = new_follow_artists.map do |id| 
                                {user_id: user.spotify_id, artist_id: id, created_at: Time.current, updated_at: Time.current}
                              end
    FollowArtist.insert_all(follow_artists)
  end
end
