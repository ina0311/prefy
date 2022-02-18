class Playlists::PlaylistInfoGetter < SpotifyService
  # プレイリストのトラック、名前、画像の取得、保存、更新
  def self.call(playlist)
    new(playlist).get
  end

  def initialize(playlist)
    @playlist = playlist
  end

  def get
    @response = request_get_playlist(@playlist.spotify_id)
    default_track_ids = @playlist.playlist_of_tracks.pluck(:track_id)
    track_ids = response_convert_track_ids
    new_track_ids = track_ids - default_track_ids
    delete_track_ids = default_track_ids - track_ids

    ActiveRecord::Base.transaction do
      new_tracks(new_track_ids) if new_track_ids.present?
      delete_tracks(delete_track_ids) if delete_track_ids.present?
      @playlist.update!(name: @response.name, image: @response.images.dig(0, 'url'))
    end
  end

  private
  
  attr_reader :playlist_id

  # 市場的に聞けない曲がnilを返すのでcompact
  def response_convert_track_ids
    @response.tracks_added_at.map(&:first).compact
  end

  def track_convert_artist_ids(tracks)
    tracks.map { |track| track.artists.map(&:id) }.flatten
  end

  def new_tracks(track_ids)
    Tracks::TrackInfoGetter.call(track_ids)
    PlaylistOfTrack.all_update(@playlist.spotify_id, track_ids)
  end

  def delete_tracks(track_ids)
    PlaylistOfTrack.specific(@playlist.spotify_id, track_ids).delete_all
  end
end