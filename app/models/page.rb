class Page < ActiveRecord::Base
  
 # belongs_to :course
    has_one :course, :as => :courseable
   has_one :lesson, :as => :lesson
  
end
