class ComplementaryCourse < ActiveRecord::Base
  validates_presence_of :course, :institution, :year, :workload
end
