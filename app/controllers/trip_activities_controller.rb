class TripActivitiesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update]
  before_action :set_trip_activity, only: [:update]

  def index
    @trip_activities = TripActivity.all
  end

  def update
    update_position_and_group if trip_activity_params[:start_date] || trip_activity_params[:position]
    if @trip_activity.save
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: @trip_activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_trip_activity
    @trip_activity = TripActivity.find(params[:id])
  end

  def trip_activity_params
    params.require(:trip_activity).permit(:start_date, :position, :new_group)
  end

  def update_position_and_group
    if trip_activity_params[:new_group].present?
      new_date = Date.parse(trip_activity_params[:new_group])
      @trip_activity.start_date = new_date
      @trip_activity.save if @trip_activity.changed?
    end
    @trip_activity.insert_at(trip_activity_params[:position].to_i + 1) if trip_activity_params[:position].present?
  end
end
