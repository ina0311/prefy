class Api::V1::PlaylistsController < ApplicationController
  include RequestUrl

  def index
    response = conn_request.get('me/playlists').body[:items]

    @playlists = current_user.playlists.find_or_create_playlists(response)

    
    binding.pry
    
  end
end
