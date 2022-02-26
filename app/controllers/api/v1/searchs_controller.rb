class Api::V1::SearchsController < ApplicationController
  def search
    response = SpotifySearcher.call(search_params)
    @artists = response[:artists]
    @albums = response[:albums]
    @tracks = response[:tracks]
    @playlist_id = current_playlist_id
  end

  private

  def search_params
    params.require('search')
  end
end
