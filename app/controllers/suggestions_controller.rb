class SuggestionsController < ApplicationController
  def show
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      format.html { render partial: "suggestions/show", locals: { suggestion: @suggestion } }
    end
  end
end
