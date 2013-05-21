# -*- encoding : utf-8 -*-
class EducationsController < ApplicationController
  respond_to :js

  load_resource :user
  load_and_authorize_resource :education, :through => :user

  def create
    @high_school = HighSchool.new
    @higher_education = HigherEducation.new
    @complementary_course = ComplementaryCourse.new
    @event_education = EventEducation.new

    if params.has_key? :high_school
      educationable = HighSchool.new(params[:high_school])
      @high_school = educationable
    elsif params.has_key? :higher_education
      educationable = HigherEducation.new(params[:higher_education])
      @higher_education = educationable
    elsif params.has_key? :complementary_course
      educationable = ComplementaryCourse.new(params[:complementary_course])
      @complementary_course = educationable
    elsif params.has_key? :event_education
      educationable = EventEducation.new(params[:event_education])
      @event_education = educationable
    end

    @education = Education.new
    @education.user = current_user
    @education.educationable = educationable
    @education.save

    if @education.valid?
      @high_school = HighSchool.new
      @higher_education = HigherEducation.new
      @complementary_course = ComplementaryCourse.new
      @event_education = EventEducation.new
    else
      @high_school ||= HighSchool.new
      @higher_education ||= HigherEducation.new
      @complementary_course ||= ComplementaryCourse.new
      @event_education ||= EventEducation.new
    end

    respond_with(@user, @education)
  end

  def update
    if params.has_key? :high_school
      @education.educationable.attributes = params[:high_school]
      @high_school = HighSchool.new
    elsif params.has_key? :higher_education
      @education.educationable.attributes = params[:higher_education]
      @higher_education = HigherEducation.new
    elsif params.has_key? :complementary_course
      @education.educationable.attributes = params[:complementary_course]
      @complementary_course = ComplementaryCourse.new
    elsif params.has_key? :event_education
      @education.educationable.attributes = params[:event_education]
      @event_education = EventEducation.new
    end
    @education.educationable.save

    respond_with(@user, @education)
  end

  def destroy
    @education.destroy

    respond_with(@user, @education)
  end

end
