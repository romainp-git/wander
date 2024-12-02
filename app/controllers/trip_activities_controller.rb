class TripActivitiesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update]
  before_action :set_trip_activity, only: [:update]


  def update
    Rails.logger.info "Updating trip_activity ##{@trip_activity.id}"
    Rails.logger.info "Params received: #{trip_activity_params.inspect}"

    if trip_activity_params[:start_date] || trip_activity_params[:position]
      update_position_and_group
    end

    if @trip_activity.save
      Rails.logger.info "TripActivity ##{@trip_activity.id} updated successfully"
      render json: { success: true }, status: :ok
    else
      Rails.logger.error "Errors: #{@trip_activity.errors.full_messages}"
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
    Rails.logger.info "Updating position and group for #{@trip_activity.id}"

    if trip_activity_params[:new_group].present?
      new_date = Date.parse(trip_activity_params[:new_group])
      Rails.logger.info "Updating start_date to: #{new_date}"
      @trip_activity.start_date = new_date

      if @trip_activity.changed?
        if @trip_activity.save
          Rails.logger.info "start_date updated successfully"
        else
          Rails.logger.error "Failed to update start_date: #{@trip_activity.errors.full_messages}"
          render json: { success: false, errors: @trip_activity.errors.full_messages }, status: :unprocessable_entity
          return
        end
      end
    end

    if trip_activity_params[:position].present?
      Rails.logger.info "Inserting at position: #{trip_activity_params[:position]}"
      @trip_activity.insert_at(trip_activity_params[:position].to_i + 1)
    end
  end
end
