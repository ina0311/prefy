class Playlists::PlaylistInfoGetter < SpotifyService
  # プレイリストのトラック、名前、画像の取得、保存、更新
  def self.call(user, playlist)
    new(user,playlist).get
  end

  def initialize(user, playlist)
    @user = user
    @playlist = playlist
  end

  def get
    response = request_get_playlist
    playlist.update!(name: response[:name], image: response.dig(:images, 0, :url))

    default = playlist.playlist_of_tracks.pluck(:track_id, :position)
    now = response_convert_track_id_and_position(response)

    new_track_id_and_positions = now - default
    delete_position_tracks = (default - now).map(&:second)

    if delete_position_tracks.present?
      delete_playlist_of_tracks = PlaylistOfTrack.identify_by_positions(playlist.spotify_id, delete_position_tracks)
      delete_playlist_of_tracks.delete_all
    end

    if new_track_id_and_positions.present?
      Tracks::TrackInfoGetter.call(user, new_track_id_and_positions.map(&:first))
      PlaylistOfTrack.insert_with_position(playlist, new_track_id_and_positions)
    end
  end

  private

  attr_reader :user, :playlist

  def response_convert_track_id_and_position(response)
    track_ids = response[:tracks][:items].pluck(:track).pluck(:id)
    track_ids.map.with_index { |id, index| [id, index] }
  end

  def request_get_playlist
    conn_request.get("playlists/#{playlist.spotify_id}").body
  end
end