module ExamsHelper
  include SchoolsHelper
  
  def seconds_to_time(number_of_seconds)
    [ number_of_seconds / 3600, number_of_seconds / 60 % 60, number_of_seconds % 60 ].map{ |t| t.to_s.rjust(2, '0') }.join(':')
  end
  
end
