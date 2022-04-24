class Users::UserPlaylistsGetter < SpotifyService
  def self.call(user)
    new(user).get
  end

  def initialize(user)
    @user = user
  end

  def get
    response = request_saved_playlists
    if response
      Playlist.all_update(response)
      defaults = user.my_playlists.pluck(:spotify_id)
      now = response.map { |res| res[:id] }
      delete_playlists = defaults - now
      add_playlists = now - defaults
      return add_playlists, delete_playlists
    else
      return response
    end
  end

  private

  attr_reader :user

  def request_saved_playlists
    playlists = []
    offset = 0
    while true
      response = conn_request.get("users/#{user.spotify_id}/playlists?limit=50&offset=#{offset}")
      if response.success?
        playlists.concat(response.body[:items])
        break if response.body.size <= 49
        offset += 50
      else
        return false
      end
    end
    return playlists
  end
end