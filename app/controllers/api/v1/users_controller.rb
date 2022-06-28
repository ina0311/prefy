class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(user_params)
    @follow_artists = @user.follow_artist_lists.sample(5)
    follow_artist_genres_top_five = @user.follow_artists.genres_name_order_desc_take_five
    @genres = Genre.where(name: follow_artist_genres_top_five.map(&:first))
    @genres.zip(follow_artist_genres_top_five.map(&:second)).each { |genre, count| genre.count = count }
  end

  def age
    @user = User.find(user_params)
    if @user.update!(age: user_age_params[:age])
      redirect_to api_v1_user_path(@user), success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render :show
    end
  end

  private

  def user_params
    params.require(:id)
  end

  def user_age_params
    params.require(:user).permit(:age)
  end
end
