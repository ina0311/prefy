class Users::UserPlaylistsGetter < SpotifyService
  def self.call(user)
    new(user).get
  end

  def initialize(user)
    @user = user
  end

  def get
    response = request_saved_playlists
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

  def request_saved_playlists
    playlists = []
    offset = 0
    while true
      response = conn_request.get("users/#{@user.spotify_id}/playlists?limit=50&offset=#{offset}").body[:items]
      playlists.concat(response)
      break if response.size <= 49
      offset += 50
    end
    playlists
  end
end