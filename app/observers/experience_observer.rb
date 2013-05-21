# -*- encoding : utf-8 -*-
class ExperienceObserver < ActiveRecord::Observer
  def after_create(experience)
    Log.setup(experience, :action => :create)
  end
end
