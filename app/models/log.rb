class Log < ActiveRecord::Base
  
  belongs_to :user
  has_many :statuses, :as => :in_response_to
  belongs_to :logeable, :polymorphic => true

  
  def self.log_activity(log_object, action, user)
    
    if user and user.my_activity.eql?(true)
    
    if log_object.instance_of?(Course)
      
      # necessário replicar a linha seguinte para cada tipo, pois as acoes reflexivas sao diferentes.
      Log.create(:logeable_type => log_object.class.to_s,
        :action => action,
        :user_id => log_object.owner.id,
        :logeable_name => log_object.name,
        :logeable_id => log_object.id)
        
      case action
        when 'create'
        log_object.owner.earn_points('created_course')
        #when 'show'
        #log_object.owner.earn_points('created_course')
      end
      
    elsif log_object.instance_of?(Resource)
       
       Log.create(:logeable_type => log_object.class.to_s,
        :action => action,
        :user_id => log_object.owner.id,
        :logeable_name => log_object.name,
        :logeable_id => log_object.id)
      
      case action
        when 'create'
        log_object.owner.earn_points('created_resource')
      end
      
      elsif log_object.instance_of?(Favorite)
       
       Log.create(:logeable_type => log_object.favoritable.class.to_s,
        :action => action,
        :user_id => log_object.user.id,
        :logeable_name => log_object.favoritable.name,
        :logeable_id => log_object.favoritable.id)
      
      
      
      elsif log_object.instance_of?(Exam)
       
       Log.create(:logeable_type => log_object.class.to_s,
        :action => action,
        :user_id => log_object.owner.id,
        :logeable_name => log_object.name,
        :logeable_id => log_object.id)
      
      case action
        when 'create'
        log_object.owner.earn_points('created_resource')
        when 'answer'
        log_object.owner.earn_points('answer_exam')
      end
      
      elsif log_object.instance_of?(User)
       
       Log.create(:logeable_type => log_object.class.to_s,
        :action => action,
        :user_id => log_object.id,
        :logeable_name => log_object.login,
        :logeable_id => log_object.id)
      
    end
    end
  end
end
