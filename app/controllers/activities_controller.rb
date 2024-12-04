class ActivitiesController < ApplicationController
  def index
    @activities = Activity.all
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def update
    @activity = Activity.find(params[:id])
    @activity.update(activity_params)
    redirect_to activity_path(@activity)
  end

  def new
    @activity = Activity.new
  end

  # def create
  #   @activity = Activity.new(activity_params)

  #   if @activity.save
  #     redirect_to trip_path(params[:trip_id]), notice: "Activity created successfully!"
  #   else
  #     render :new, alert: "Failed to create activity."
  #   end
  # end

  def destroy
  end

  def activity_params
    params.require(:activity).permit(:name, :address, :description, photos: [])
  end
end
