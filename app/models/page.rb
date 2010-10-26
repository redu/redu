class Page < ActiveRecord::Base

  validates_presence_of :body
  
  has_one :lecture, :as => :lectureable
  has_one :lesson, :as => :lesson

end
