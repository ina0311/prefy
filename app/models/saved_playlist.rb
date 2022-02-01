class SavedPlaylist < ApplicationRecord
  include RequestUrl

  belongs_to :user
  belongs_to :playlist
  validates :user_id, uniqueness: { scope: :playlist_id }
  
  # その他のバリデーションはFormに記載

  has_many :saved_playlist_genres, dependent: :destroy
  has_many :genres, through: :saved_playlist_genres

  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :include_artists, through: :saved_playlist_include_artists, source: :artist

  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :include_tracks, through: :saved_playlist_include_tracks

  enum that_generation_preference: %i(junior_high_school high_school university 20s 30s)

  def self.list_get(playlist_attributes, user)
    SavedPlaylist.list_update(playlist_attributes, user)

    user.my_playlists.all
  end

  def self.list_update(playlist_attributes, user)
    Playlist.all_update(playlist_attributes)

    default_saved_playlist_ids = user.my_playlists.pluck(:spotify_id)
    now_my_playlist_ids = playlist_attributes.pluck(:spotify_id)
    deleted_my_playlist_ids = default_saved_playlist_ids - now_my_playlist_ids
    add_my_playlist_ids = now_my_playlist_ids - default_saved_playlist_ids

    SavedPlaylist.destroy_from_my_playlist(deleted_my_playlist_ids, user) if deleted_my_playlist_ids.present?
    SavedPlaylist.add_my_playlist(add_my_playlist_ids, user) if add_my_playlist_ids.present?
  end

  def self.destroy_from_my_playlist(deleted_my_playlist_ids, user)
    Playlist.my_playlists(deleted_my_playlist_ids, user.spotify_id).destroy_all
  end

  def self.add_my_playlist(add_my_playlist_ids, user)
    saved_playlists = Playlist.where(spotify_id: add_my_playlist_ids).ids
    saved_playlist_atttibutes = saved_playlists.map do |id|
                                  {user_id: user.id, playlist_id: id, created_at: Time.current, updated_at: Time.current}
                                end
    SavedPlaylist.insert_all(saved_playlist_atttibutes)
  end
end
