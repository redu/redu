module CoursesHelper
	def setup_course(course)
		returning course do | course |
			#setup_main_resource(course)
			#setup_prices(course)
		end
	end
	
	def setup_main_resource(course)
	  if course
		returning course do |course|
			course.main_resource = Resource.new if course.main_resource.nil?
		end
    end
	end
	
	def setup_prices(course)
		returning course do |course|
			if course.course_prices.empty?
				course.course_prices << CoursePrice.new(:key_number => 1)
				course.course_prices << CoursePrice.new(:key_number => 100)
				course.course_prices << CoursePrice.new(:key_number => 500)
				course.course_prices << CoursePrice.new(:key_number => 1000)
			end
		end
	end
	
	def users_resource?(resource)
		if @course
			@course.resources.include?(resource)
		else
			false
		end
	end
	
	def main_resource?(resource)
    if @course
      @course.main_resource.eql?(resource)
    else
     false
    end
  end
	
	
end
