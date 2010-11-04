class EnrollmentsController < ApplicationController
  before_filter :login_required
  before_filter :verify_access


  def create
    @enrollment = Enrollment.new(params[:enrollment])
  end


end
