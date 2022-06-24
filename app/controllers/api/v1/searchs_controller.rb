class Api::V1::SearchsController < ApplicationController
  before_action :delete_current_playlist, only: %i[index]

  def index; end

  def search
    response = SpotifySearcher.call(URI.encode_www_form_component(search_params), current_user).search
    return js_format_flash_message(:danger, t("message.not_get_for_search_word")) if response.nil?

    @artists = response[:artists]
    @albums = response[:albums]
    @tracks = response[:tracks]
    @follow_artist_ids = current_user.follow_artist_lists.ids
  end

  def artists
    @artists = SpotifySearcher.call(URI.encode_www_form_component(search_params), current_user).artists
    return js_format_flash_message(:danger, t("message.not_get_for_search_word")) if @artists.nil?

    @follow_artist_ids = current_user.follow_artists.pluck(:artist_id)
  end

  private

  def search_params
    params.require('search')
  end
end
