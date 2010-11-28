class Page < ActiveRecord::Base
  
  has_one :lecture, :as => :lectureable
  has_one :lesson, :as => :lesson
  has_many :assets, :as => :assetable

  validates_presence_of :body

end
