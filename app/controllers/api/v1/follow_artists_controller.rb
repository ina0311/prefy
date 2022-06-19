class Api::V1::FollowArtistsController < ApplicationController
  def index
    @q =  Artist.joins(:users).where('users.spotify_id = ?', current_user).ransack(params[:q])
    @genre = Genre.find(params[:q][:genres_id_eq]) if params[:q]
    @follow_artists = @q.result(distinct: true)
  end

  def create
    @artist_id = follow_artist_params
    Users::ArtistFollower.call(current_user, @artist_id)
    artist_name = current_user.follow_artist_lists.find_by(spotify_id: @artist_id).name
    js_format_flash_message(:success, t(".success", item: artist_name))
  end

  def destroy
    @artist_id = follow_artist_params
    follow_artist = FollowArtist.find_by(user_id: current_user.spotify_id, artist_id: @artist_id)
    Users::FollowArtistUnfollower.call(@current_user, follow_artist)
    artist_name = Artist.find_by(spotify_id: @artist_id).name
    js_format_flash_message(:success, t(".success", item: artist_name))
  end

  private

  def follow_artist_params
    params.require(:artist_id)
  end
end
