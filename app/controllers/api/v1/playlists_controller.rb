class Api::V1::PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.find(playlist_params)
    Playlists::PlaylistInfoGetter.call(current_user, @playlist) unless current_user.guest_user?
    @tracks = @playlist.tracks.includes(album: :artists).position_asc
    @form = SavedPlaylistForm.new(saved_playlist: @playlist.saved_playlist)
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
