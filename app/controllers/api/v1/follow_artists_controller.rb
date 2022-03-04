class Api::V1::FollowArtistsController < ApplicationController
  def index
    @follow_artists = current_user.follow_artist_lists.all
  end

  def destroy
    @follow_artist = FollowArtist.find_by(user_id: current_user, artist_id: unfollow_artist_params)
    Users::FollowArtistUnfollower.call(@current_user, @follow_artist)
  end

  private

  def unfollow_artist_params
    params.require(:id)
  end
end
