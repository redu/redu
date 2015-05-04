class HierarchyNotification
  include Mongoid::Document
  include Mongoid::Timestamps
  set_database :vis

  field :user_id, :type => Integer
  field :type
  field :lecture_id, :type => Integer
  field :subject_id, :type => Integer
  field :space_id, :type => Integer
  field :course_id, :type => Integer
  field :status_id, :type => Integer
  field :statusable_id, :type => Integer
  field :statusable_type
  field :in_response_to_id, :type => Integer
  field :in_response_to_type
  field :grade, :type => Float

  validates_presence_of :user_id
  validates_presence_of :type

end

def insert_enrollments_on_vis(date)
  Enrollment.where("created_at >= '#{date}'").find_in_batches do |enrollment_group|
    batch = []
    enrollment_group.each do |enrollment|
      unless enrollment.subject.nil?
        unless enrollment.subject.space.nil?
          unless enrollment.subject.space.course.nil?
            params_enroll = fill_enroll(enrollment, "enrollment")
            hn = HierarchyNotification.new(params_enroll)
            batch << hn.as_document
          end
        end
      end
    end
    HierarchyNotification.collection.insert(batch)
  end
end

def insert_subject_finalized_on_vis(date)
  Enrollment.where("grade = 100 AND graduated = true AND created_at >= '#{date}'").find_in_batches do |group_finalized|
    batch = []
    group_finalized.each do |finalized|
      params_finalized = fill_enroll(finalized, "subject_finalized")
      hn = HierarchyNotification.new(params_finalized)
      batch << hn.as_document
    end

    HierarchyNotification.collection.insert(batch)
  end
end

def insert_exercise_finalized_on_vis(date)
  Result.finalized.where("created_at > '#{date}'").find_in_batches do |group_result|
    batch = []
    group_result.each do |result|
      params_result = fill_exercise(result)
      hn = HierarchyNotification.new(params_result)
      batch << hn.as_document
    end
    HierarchyNotification.collection.insert(batch)
  end
end

def fill_params_status(lecture, subject, space, course)
{
  @lecture_id = lecture
  @subject_id = subject
  @space_id   = space
  @course_id  = course
}

def insert_statuses_on_vis(date)
  Status.where("type IN ('Activity', 'Help', 'Answer') AND created_at >= '#{date}'").find_in_batches do |status_group|
    batch = []
    status_group.each do |status|
      # Filling params according type of the Status
      case status.statusable.class.to_s
      when "Lecture"
        fill_params_status(status.statusable_id, status.statusable.subject.id, status.statusable.subject.space.id, status.statusable.subject.space.course.id)
        
        params_status = fill_status(status)
      when "Space"
        fill_params_status(nil, nil, status.statusable.id, status.statusable.course.id)
        
        params_status = fill_status(status)
      when "Activity", "Help"
        statusable = status.statusable
        case statusable.statusable.class.to_s
        when "Lecture"
          fill_params_status(statusable.statusable_id, statusable.statusable.subject.id, statusable.statusable.subject.space.id, statusable.statusable.subject.space.course.id)
          
          params_status = fill_status(status)
        when "Space"
          fill_params_status(nil, nil, statusable.statusable.id, statusable.statusable.course.id)
          
          params_status = fill_status(status)
        end
      end
      hn = HierarchyNotification.new(params_status)
      batch << hn.as_document
    end
    HierarchyNotification.collection.insert(batch)
  end
end

def fill_status(status)
  params_status = {
    :user_id => status.user_id,
    :type => get_type(status),
    :lecture_id => @lecture_id,
    :subject_id => @subject_id,
    :space_id => @space_id,
    :course_id => @course_id,
    :status_id => status.id,
    :statusable_id => status.statusable_id,
    :statusable_type => status.statusable_type,
    :in_response_to_id => status.in_response_to_id,
    :in_response_to_type => status.in_response_to_type,
    :created_at => status.created_at,
    :updated_at => status.updated_at
  }
end

def get_type(status)
  if status.type == "Help" or status.type == "Activity"
    status.type.downcase
  elsif status.type == "Answer"
    if status.statusable.type == "Help"
      "answered_help"
    else
      "answered_activity"
    end
  else
    nil
  end
end

def fill_enroll(enrollment, type)
  params_enrol = {
    :user_id => enrollment.user_id,
    :type => type,
    :lecture_id => nil,
    :subject_id => enrollment.subject_id,
    :space_id => enrollment.subject.space.id,
    :course_id => enrollment.subject.space.course.id,
    :status_id => nil,
    :statusable_id => nil,
    :statusable_type => nil,
    :in_response_to_id => nil,
    :in_response_to_type => nil,
    :created_at => enrollment.created_at,
    :updated_at => enrollment.updated_at
  }
end

def fill_exercise(result)
  exercise = result.exercise
  space = exercise.lecture.subject.space
  params = {
    :lecture_id => exercise.lecture.id,
    :subject_id => exercise.lecture.subject.id,
    :space_id => space.id,
    :course_id => space.course.id,
    :user_id => result.user_id,
    :type => "exercise_finalized",
    :grade => result.grade,
    :status_id => nil,
    :statusable_id => nil,
    :statusable_type => nil,
    :in_response_to_id => nil,
    :in_response_to_type => nil,
    :created_at => result.created_at,
    :updated_at => result.updated_at
  }
end
