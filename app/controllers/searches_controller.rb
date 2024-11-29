class SearchesController < ApplicationController
  def new

  end

  def create
    @search = Search.new(search_params)

    if @search.save
      OpenaiService.new(@search).generate_program
      trip = Trip.find(@search.trip_id)
      redirect_to trip_path(trip)
    else
      render :new
    end
  end

  def launch
    @search = Search.find(params[:id])
  end

  def show
    @search = Search.find(params[:id])
  end

  private

  def search_params
    params[:search][:categories] = params[:search][:categories].reject { |category| category == "0" } if params[:search][:categories].is_a?(Array)
    params.require(:search).permit(:destination, :inspiration, :start_date, :end_date, :nb_infants, :nb_adults, :nb_children, { categories: [] }, :options)
  end
end
