class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to trips_path(@user), notice: 'Votre profil a été mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:last_name, :first_name, :username, :address, :photo)
  end
end
