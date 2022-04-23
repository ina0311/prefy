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

    @playlist.update!(name: response[:name], image: response.dig(:images, 0, :url))

    default = @playlist.playlist_of_tracks.pluck(:track_id, :position)
    now = response_convert_track_id_and_position(response)

    new_track_id_and_position = now - default
    delete_track_id_and_position = default - now

    ActiveRecord::Base.transaction do
      if new_track_id_and_position.present?
        playlist_of_tracks = new_track_id_and_position.map do |ary|
          @playlist.playlist_of_tracks.new(track_id: ary.first, position: ary.second)
        end
        Tracks::TrackInfoGetter.call(playlist_of_tracks.pluck(:track_id))
        PlaylistOfTrack.import!(playlist_of_tracks)
      end
      PlaylistOfTrack.specific(@playlist.spotify_id, delete_track_id_and_position.map(&:second)).delete_all if delete_track_id_and_position.present?
    end
  end

  private

  def response_convert_track_id_and_position(response)
    track_ids = response[:tracks][:items].pluck(:track).pluck(:id)
    track_ids.map.with_index { |id, index| [id, index] }
  end

  def request_get_playlist
    conn_request.get("playlists/#{@playlist.spotify_id}").body
  end
end