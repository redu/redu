class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    Log.setup(model, :action => :update)
  end
end
