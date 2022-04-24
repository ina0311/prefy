class Api::V1::PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.find(playlist_params)
    Playlists::PlaylistInfoGetter.call(current_user, @playlist) unless current_user.guest_user?
    @playlist_of_tracks = @playlist.playlist_of_tracks.includes(track: [album: :artists]).position_asc
    @form = SavedPlaylistForm.new(saved_playlist: @playlist.saved_playlist) if current_user.own?(@playlist)
    session[:playlist_id] = @playlist.spotify_id
  end

  def edit
    @playlist_of_tracks = PlaylistOfTrack.includes(track: [album: :artists]).where(playlist_id: playlist_params).position_asc
  end

  private

  def playlist_params
    params.require('id')
  end
end
