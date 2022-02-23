class Api::V1::PlaylistOfTracksController < ApplicationController
  def create

  end

  def destroy
    @playlist_of_track = set_playlist_of_track(playlist_of_track_params)
    Playlists::PlaylistTracksRemover.call(current_user, @playlist_of_track.playlist_id, @playlist_of_track.track_id)
  end

  private

  def playlist_of_track_params
    params.permit(:playlist_id, :track_id)
  end

  def set_playlist_of_track(playlist_of_track_params)
    PlaylistOfTrack.find_by(playlist_id: playlist_of_track_params[:playlist_id], track_id: playlist_of_track_params[:track_id])
  end
end
