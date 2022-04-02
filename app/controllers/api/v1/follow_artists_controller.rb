class Api::V1::FollowArtistsController < ApplicationController
  def index
    @follow_artists = current_user.follow_artist_lists.all
  end

  def create
    @artist_id = follow_artist_params
    Users::ArtistFollower.call(current_user, @artist_id)
    js_format_flash_message(:success, t(".success"))
  end

  def destroy
    @artist_id = follow_artist_params
    follow_artist = FollowArtist.find_by(user_id: current_user.spotify_id, artist_id: @artist_id)
    Users::FollowArtistUnfollower.call(@current_user, follow_artist)
    js_format_flash_message(:success, t(".success"))
  end

  private

  def follow_artist_params
    params.require(:artist_id)
  end
end
