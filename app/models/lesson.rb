class Lesson < ActiveRecord::Base
  
  belongs_to :interactive_class
 #acts_as_list :scope => :interactive_class #NAO USE 


  
end
