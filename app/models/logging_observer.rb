class LoggingObserver < ActiveRecord::Observer
  observe :user

  def after_create(model)
  end

end
