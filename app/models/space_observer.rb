class SpaceObserver < ActiveRecord::Observer
  def after_create(space)
    Log.setup(space, :action => :create, :text => "criou a disciplina")
  end
end
