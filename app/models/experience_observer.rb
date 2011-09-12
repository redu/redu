class ExperienceObserver < ActiveRecord::Observer
  def after_create(experience)
    Log.setup(experience, :text => "adicionou uma nova experiência no currículo")
  end
end
