class HighSchool < ActiveRecord::Base
  validates_presence_of :institution, :end_year
end
