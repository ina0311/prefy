class Api::V1::PlaylistsController < ApplicationController

  def show
    @playlist = Playlist.includes(:playlist_of_tracks).find(params[:id])

    Playlists::PlaylistInfoGetter.call(@playlist)
    @tracks = @playlist.included_tracks.includes(album: :artists)
    @form = SavedPlaylistForm.new(saved_playlist: @playlist.saved_playlist)
  end
end
