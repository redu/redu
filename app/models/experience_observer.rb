class ExperienceObserver < ActiveRecord::Observer
  def after_create(experience)
    Log.setup(experience)
  end
end
