class Playlists::PlaylistInfoGetter < SpotifyService
  def self.call(playlist_id)
    new(playlist_id).get
  end

  def initialize(playlist_id)
    @playlist_id = playlist_id
  end

  def get
    @response = request_get_playlist(@playlist_id)
    tracks = request_get_tracks(response_convert_track_ids)
    albums = tracks.map(&:album)
    Album.all_insert(albums)
    Track.all_import(tracks)
    Artists::ArtistRegistrar.call(track_convert_artist_ids(tracks), albums)
    PlaylistOfTrack.all_update(@playlist_id, tracks.map(&:id))
  end

  private
  
  attr_reader :playlist_id

  def response_convert_track_ids
    @response.tracks_added_at.map(&:first)
  end

  def track_convert_artist_ids(tracks)
    tracks.map { |track| track.artists.map(&:id) }.flatten
  end
end