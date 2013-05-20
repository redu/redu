# -*- encoding : utf-8 -*-
class ExperiencesController < ApplicationController
  respond_to :js

  load_resource :user
  load_and_authorize_resource :experience, :through => :user

  def create
    if params[:experience][:current] == "1"
      params[:experience]["end_date(1i)"] = ""
      params[:experience]["end_date(2i)"] = ""
      params[:experience]["end_date(3i)"] = ""
    end
    @experience = Experience.new(params[:experience])
    @experience.user = current_user
    @experience.save

    respond_with(@user, @experience)
  end

  def edit
  end

  def update
    if params[:experience][:current] == "1"
      params[:experience]["end_date(1i)"] = ""
      params[:experience]["end_date(2i)"] = ""
      params[:experience]["end_date(3i)"] = ""
    end
    @experience.attributes = params[:experience]
    @experience.save
  end

  def destroy
    @experience.destroy
  end

end
