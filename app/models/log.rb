class Log < ActiveRecord::Base
  
  belongs_to :user
  has_many :statuses, :as => :in_response_to
  belongs_to :logeable, :polymorphic => true

  
  def self.log_activity(object, action, user) 
    
    if object.instance_of?(Course)
      
      Log.create(:logeable_type => 'course',
        :action => action,
        :user_id => object.owner.id,
        :logeable_name => object.name,
        :logeable_id => object.id)
      
      
      case action
        when 'create'
        object.owner.earn_points('created_course')
        #when 'show'
        #object.owner.earn_points('created_course')
      end
      
    elsif object.instance_of?(Resource)
       
       Log.create(:logeable_type => 'resource',
        :action => action,
        :user_id => object.owner.id,
        :logeable_name => object.name,
        :logeable_id => object.id)
      
      case action
        when 'create'
        object.owner.earn_points('created_resource')
      end
      
      elsif object.instance_of?(Exam)
       
       Log.create(:logeable_type => 'exam',
        :action => action,
        :user_id => object.owner.id,
        :logeable_name => object.name,
        :logeable_id => object.id)
      
      case action
        when 'create'
        object.owner.earn_points('created_resource')
        when 'answer'
        object.owner.earn_points('answer_exam')
      end
      
      elsif object.instance_of?(User)
       
       Log.create(:logeable_type => 'user',
        :action => action,
        :user_id => object.id,
        :logeable_name => object.login,
        :logeable_id => object.id)
      
    end
  end
end
