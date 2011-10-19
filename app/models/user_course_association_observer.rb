class UserCourseAssociationObserver < ActiveRecord::Observer
  def after_create(model)
    if model.waiting? && model.course.subscription_type.eql?(2)
      model.notify_pending_moderation
    end
  end
end
