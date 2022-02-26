class Api::V1::PlaylistOfTracksController < ApplicationController
  def update
    playlist_id, track_id = add_playlist_id_and_track_id(playlist_of_track_params)
    Playlists::PlaylistTrackAdder.call(current_user, playlist_id, track_id)
    @playlist_of_track = PlaylistOfTrack.includes(track: [album: :artists]).find_by(playlist_id: playlist_id, track_id: track_id)
  end

  def destroy
    @playlist_of_track = delete_playlist_of_track(playlist_of_track_params)
    Playlists::PlaylistTracksRemover.call(current_user, @playlist_of_track.playlist_id, @playlist_of_track.track_id)
  end

  private

  def playlist_of_track_params
    params.permit(:playlist_id, :id)
  end

  def delete_playlist_of_track(playlist_of_track_params)
    PlaylistOfTrack.find(playlist_of_track_params[:id])
  end

  def add_playlist_id_and_track_id(playlist_of_track_params)
    playlist_id = playlist_of_track_params[:playlist_id]
    track_id = playlist_of_track_params[:id]
    return playlist_id, track_id
  end
end
