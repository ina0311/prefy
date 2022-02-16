class Users::PlaylistsGetter < SpotifyService
  def self.call(user)
    new(user).get
  end

  def initialize(user)
    @user = user
  end

  def get
    response = request_saved_playlists(@user)
    Playlist.all_update(response)
    defaults = @user.my_playlists.pluck(:spotify_id)
    now = response.map { |res| res[:id] }

    delete_playlists(now, defaults)
    add_my_playlists(now, defaults)
  end

  private

  attr_reader :user

  def delete_playlists(now, defaults)
    result = defaults - now
    return if result.blank?
    ActiveRecord::Base.transaction do
      owns = Playlist.my_playlists(result, @user.spotify_id)
      owns.destroy_all if owns.present?
      result = result - owns
      SavedPlaylist.delete_from_my_playlists(result, @user.spotify_id) if result.present?
    end
  end

  def add_my_playlists(now, defaults)
    result = now - defaults
    return if result.blank?
    SavedPlaylist.add_my_playlists(result, @user.spotify_id)
  end
end