class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(user_params)
  end

  def age
    @user = User.find(user_params)
    if @user.update!(age: user_age_params[:age])
      redirect_to api_v1_user_path(@user)
    else
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
