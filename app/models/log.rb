class Log < ActiveRecord::Base
  belongs_to :user
  has_many :statuses, :as => :in_response_to
  belongs_to :logeable, :polymorphic => true
  
  def self.log_activity(log_object, action, user, school)
  
    if log_object.instance_of?(Course)
      create_logs(log_object, action, user, school)
      case action
        when 'create'
        log_object.owner.earn_points('created_course')
      end
    elsif log_object.instance_of?(Resource)
      create_logs(log_object, action, user, school)
      case action
        when 'create'
        log_object.owner.earn_points('created_resource')
      end
    elsif log_object.instance_of?(Favorite)
      create_logs(log_object, action, user, school)
    elsif log_object.instance_of?(Exam)
       
      create_logs(log_object, action, user, school)
      case action
        when 'create'
          log_object.owner.earn_points('created_exam')
        when 'answer'
          log_object.owner.earn_points('answer_exam')
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



