class SeminarObserver < ActiveRecord::Observer
  def after_create(seminar)
    if seminar.external?
      seminar.update_attributes(:state => "converted")
    end
  end
end
