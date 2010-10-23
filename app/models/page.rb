class Page < ActiveRecord::Base

  validates_presence_of :body
  
  has_one :course, :as => :courseable
  has_one :lesson, :as => :lesson

end
