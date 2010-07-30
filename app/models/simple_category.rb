class SimpleCategory < ActiveRecord::Base
  
  has_many :courses
  has_many :exams
end
