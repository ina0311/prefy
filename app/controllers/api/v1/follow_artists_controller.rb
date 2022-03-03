class Api::V1::FollowArtistsController < ApplicationController
  def index
    @follow_artists = current_user.follow_artist_lists.all
  end
end
