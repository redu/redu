class SpaceObserver < ActiveRecord::Observer
  def after_create(space)
    space.notify_space_added if space.notificable?
    Log.setup(space, :action => :create)
  end
end
