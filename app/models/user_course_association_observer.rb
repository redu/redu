class UserCourseAssociationObserver < ActiveRecord::Observer
  def after_update(uca)
    Log.setup(uca, :action => :create, :text => 'ingressou no curso')
  end
end
