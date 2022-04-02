class Api::V1::PlaylistOfTracksController < ApplicationController
  def create
    playlist_of_track = PlaylistOfTrack.new(playlist_id: playlist_of_track_params[:playlist_id], track_id: playlist_of_track_params[:track_id])
    @playlist_of_track = Playlists::PlaylistTrackAdder.call(current_user, playlist_of_track)
    js_format_flash_message(:success, t("message.add_track_to_playlist"))
  end

  def destroy
    playlist_of_track = PlaylistOfTrack.find(playlist_of_track_params[:id])
    Playlists::PlaylistTrackRemover.call(current_user, playlist_of_track)
    @playlist_of_tracks = PlaylistOfTrack.includes(track: [album: :artists]).where(playlist_id: playlist_of_track.playlist_id)
    js_format_flash_message(:success, t("message.delete_track_from_playlist"))
  end

  private

  def playlist_of_track_params
    params.permit(:id, :playlist_id, :track_id)
  end
end
