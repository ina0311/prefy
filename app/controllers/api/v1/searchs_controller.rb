class Api::V1::SearchsController < ApplicationController
  def search
    @response = SpotifySearcher.call(search_params)
  end

  private

  def search_params
    params.require('search')
  end
end
