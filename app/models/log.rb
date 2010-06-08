class Log < ActiveRecord::Base
  
  belongs_to :user
  has_many :statuses, :as => :in_response_to
  belongs_to :logeable, :polymorphic => true

  
  def self.log_activity(log_object, action, user, school)

    if user and user.my_activity.eql?(true)
    
    if log_object.instance_of?(Course)
      
      create_logs(log_object, action, user, school)
        
      case action
        when 'create'
        log_object.owner.earn_points('created_course')
#        when 'show'
#       log_object.owner.earn_points('show_course')
#        when 'update'
#        log_object.owner.earn_points('updated_course') # COMO ASSIM? O CARA GANHA PONTOS SE ATUALIZAR?
      end
      
    elsif log_object.instance_of?(Resource)
       
      create_logs(log_object, action, user, school)
      
      case action
        when 'create'
        log_object.owner.earn_points('created_resource')
#        when 'show'
#        log_object.owner.earn_points('show_resource')
      end
      
      elsif log_object.instance_of?(Favorite)
       
      create_logs(log_object, action, user, school)
      
      ## POINTS TO Favorites
      
      elsif log_object.instance_of?(Exam)
       
      create_logs(log_object, action, user, school)
      
      case action
        when 'create'
        log_object.owner.earn_points('created_exam')
        when 'answer'
        log_object.owner.earn_points('answer_exam')
#        when 'show'
#        log_object.owner.earn_points('show_exam')
#        when 'update'
#        log_object.owner.earn_points('updated_exam')
      end
      
      elsif log_object.instance_of?(User)
       
    end
    end
  end
  
  def self.create_logs(log_object, action, user, school = nil)
        Log.create(:logeable_type => log_object.class.to_s,
          :action => action,
          :user_id => user.id,
          :logeable_name => log_object.name,
          :logeable_id => log_object.id,
          :school_id => (school) ? school.id : nil)
  end
  
end



