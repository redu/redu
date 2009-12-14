class CreateCourseController < BaseController
	
	act_wizardly_for :course,
		:completed => '/courses',
		:canceled => '/main',
		:form_date => :sandbox,
		:persist_model => :per_page
		
		on_get(:step1) do
			puts "on_get"
			puts session[:user]
			@course.owner = current_user
			puts @course.owner
		end
		
		on_get(:step2) do
			@resource = Resource.new
		end
		
		on_post(:step2) do
			if params[:external_resource_type] == "media" then
				params[:external_resource] = nil
			else
				params[:media] = nil
			end
			
		  resource = Resource.new(:title => params[:title], 
		  	:description => params[:description],
		  	:owner => current_user,
		  	:external_resource => params[:external_resource],
		  	:external_resource_type => params[:external_resource_type],
		  	:media => params[:media])
		  
		  if resource.save! 
		  	if resource.video?
		  		resource.convert
		  	end
		 	end
			
			CourseResourceAssociation.new(:course_id => @course.id, 
				:resource_id => resource.id, 
				:main_resource => true).save
				
			
		end
		
		def current_user 
			User.find(session[:user])
		end
end
