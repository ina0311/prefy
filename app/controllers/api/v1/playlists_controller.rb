class Api::V1::PlaylistsController < ApplicationController

  def show
    @playlist = Playlist.find(params[:id])

    Playlists::PlaylistInfoGetter.call(@playlist.spotify_id) unless @playlist.included_tracks.present?
    @tracks = @playlist.included_tracks.includes(album: :artists)
  end
end
