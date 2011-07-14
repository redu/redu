class EducationsController < ApplicationController
  respond_to :js

  load_resource :user
  load_and_authorize_resource :education, :through => :user

  def create
    @high_school = HighSchool.new(params[:high_school])
    @education = Education.new
    @education.user = current_user
    @education.educationable = @high_school
    @education.save

    respond_with(@user, @education)
  end

  def update
    @education.educationable.attributes = params[:high_school]
    @education.educationable.save

    respond_with(@user, @education)
  end

  def destroy
    @education.destroy

    respond_with(@user, @education)
  end

end
