class SimpleCategory < ActiveRecord::Base
  
  has_many :lectures
  has_many :exams

end
