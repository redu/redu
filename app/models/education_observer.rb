class EducationObserver < ActiveRecord::Observer
  def after_create(education)
    Log.setup(education)
  end
end
