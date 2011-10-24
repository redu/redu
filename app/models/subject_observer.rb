class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    model.notify_subject_added
    Log.setup(model, :action => :update)
  end
end
