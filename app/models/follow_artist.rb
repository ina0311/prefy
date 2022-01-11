class FollowArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }

  def self.list_update(params, user)
    default_follow_artist_ids = user.follow_artist_lists.pluck(:spotify_id)
    now_follow_artist_ids = params.pluck(:id)

    unfollow_artists_ids = default_follow_artist_ids - now_follow_artist_ids
    new_follow_artist_ids = now_follow_artist_ids - default_follow_artist_ids

    FollowArtist.unfollow(unfollow_artists_ids, user) if unfollow_artists_ids.present?


    if new_follow_artist_ids.present?
      new_follow_artists = []
      params.each do |prm|
        new_follow_artists << prm if new_follow_artist?(prm, new_follow_artist_ids)
        new_follow_artist_ids.delete(prm[:id])
        break if !new_follow_artist_ids.present?
      end
      FollowArtist.follow(new_follow_artists, user)
      binding.pry
    end
  end

  def self.follow(params, user)
    params.each do |prm|
      artist = Artist.find_or_create_artist(prm)
      follow_artist = user.follow_artists.create(artist_id: artist.id) 
    end
    binding.pry
    
  end

  def self.unfollow(unfollow_artists, user)
    unfollow_artists.each { |id| user.follow_artist_lists.delete(spotify_id: id) }
  end

  def self.new_follow_artist?(prm, ids)
    ids.each do |id|
      return true if prm[:id] == id
    end
  end
end
