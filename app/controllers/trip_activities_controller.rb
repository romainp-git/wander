class TripActivitiesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update, :destroy]
  before_action :set_trip_activity, only: [:update, :destroy]

  def update
    update_position_and_group if trip_activity_params[:start_date] || trip_activity_params[:position]
    if @trip_activity.save
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: @trip_activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    @trip = Trip.find(params[:trip_id])
    @activity = Activity.create(trip_activity_params[:activity]) # On suppose que l'utilisateur a sélectionné une activité existante ou en a créé une.
    @trip_activity = @trip.trip_activities.new(
      activity: @activity,
      start_date: params[:trip_activity][:start_date],
      end_date: params[:trip_activity][:end_date]
    )
    if @trip_activity.save
      redirect_to trip_path(@trip), notice: 'Activity added to your trip successfully!'
    else
      redirect_to trip_path(@trip), alert: 'Failed to add activity to your trip.'
    end
  end

  def destroy
    @trip_activity = TripActivity.find(params[:id])

    if @trip_activity.destroy
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
    params.require(:trip_activity).permit(:start_date, :end_date, :position, :new_group, activity: {})
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
