class ExternalObject < ActiveRecord::Base
 #belongs_to :course
  
   has_one :lesson, :as => :lesson

end
