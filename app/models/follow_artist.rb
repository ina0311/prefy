class FollowArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }

  scope :genres_id_order_desc, -> { joins(artist: [artist_genres: :genre]).group("genres.id").having('count(*) >= ?', 3).order("count_all DESC").count }
  scope :genres_name_order_desc_take_five, -> { joins(artist: :genres).group("genres.name").order("count_all DESC").count.take(5) }

  def self.unfollow_all(unfollow_artists, user)
    FollowArtist.transaction do
      user.follow_artists.where(artist_id: unfollow_artists).destroy_all
    end
  end

  def self.follow_all(new_follow_artists, user)
    follow_artists = new_follow_artists.map do |id|
      user.follow_artists.new(artist_id: id)
    end
    FollowArtist.import!(follow_artists, ignore: true)
  end
end
