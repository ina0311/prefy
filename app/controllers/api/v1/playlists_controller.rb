class Api::V1::PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.includes(:playlist_of_tracks).find(playlist_params)

    Playlists::PlaylistInfoGetter.call(@playlist) unless current_user.guest_user?
    @tracks = @playlist.included_tracks.includes(album: :artists)
    @form = SavedPlaylistForm.new(saved_playlist: @playlist.saved_playlist)
    gon.user = current_user
    session[:playlist_id] = @playlist[:spotify_id]
  end

  def edit
    @playlist = Playlist.includes(playlist_of_tracks: [track: [album: :artists]]).find(playlist_params)
  end

  private

  def playlist_params
    params.require('id')
  end
end
