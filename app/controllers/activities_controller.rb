class ActivitiesController < ApplicationController
  def index
    @activities = current_user.activities
    render json: @activities, serializers: PublicActivity::ActivitySerializer
  end
end
