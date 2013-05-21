# -*- encoding : utf-8 -*-
class PagesController < ApplicationController
  def show
    render :template => page_finder.template, :layout => page_finder.layout
  end

  private

  def page_finder
    @finder ||= StaticPageFinder.new(:page_id => params[:id].to_s)
  end
end
