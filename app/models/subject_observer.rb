class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    Log.setup(model, :action => :update, :text => "criou o módulo")
  end
end
