class Page < ActiveRecord::Base

  has_one :lecture, :as => :lectureable
  #FIXME Verificar InteractiveClass
  has_one :lesson, :as => :lesson

  validates_presence_of :body

end
