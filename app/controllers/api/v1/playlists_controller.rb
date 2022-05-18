class Api::V1::PlaylistsController < ApplicationController
  def edit
    @playlist_of_tracks = PlaylistOfTrack.includes(track: [album: :artists]).where(playlist_id: playlist_params).position_asc
  end

  private

  def playlist_params
    params.require('id')
  end
end
