class SpaceObserver < ActiveRecord::Observer
  def after_create(space)
    Log.setup(space)
  end
end
