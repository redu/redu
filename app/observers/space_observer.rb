class SpaceObserver < ActiveRecord::Observer
  def after_create(space)
    space.delay_notify_space_added if space.notificable?
    Log.setup(space, :action => :create)
  end
end
