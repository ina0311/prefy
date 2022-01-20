class Api::V1::PlaylistsController < ApplicationController

  def show
    @playlist = Playlist.find(params[:id])

    if @playlist.included_tracks.present?
      @tracks = @playlist.included_tracks.includes(album: :artist)
    else
      playlist_info = conn_request_playlist_info(@playlist)
      @playlist.info_update(playlist_info, @playlist.spotify_id) if playlist_info.present?

      @tracks = @playlist.included_tracks.includes(album: :artist)
    end
  end
end
