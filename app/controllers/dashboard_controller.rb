class DashboardController < ApplicationController
  def index
    @course = Course.find(params[:id_course])
  end
end
