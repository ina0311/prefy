class Api::V1::SearchsController < ApplicationController
  def index; end

  def search
    response = SpotifySearcher.call(search_params).search
    return js_format_flash_message(:danger, t("message.not_get_for_search_word")) if response.nil?
    
    @artists = response[:artists]
    @albums = response[:albums]
    @tracks = response[:tracks]
    @playlist_id = current_playlist_id
  end

  def artists
    @artists = SpotifySearcher.call(search_params).artists
    @follow_artist_ids = current_user.follow_artists.pluck(:artist_id)
  end

  private

  def search_params
    params.require('search')
  end
end
