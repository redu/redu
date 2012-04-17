def insert_enrollments
  params_array = []

  Enrollment.all.each do |enrollment|
    params_enrol = {
      :user_id => enrollment.user_id,
      :type => "enrollment",
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

    params_array << params_enrol
  end

  Delayed::Job.enqueue MigrationVisJob.new(params_array)
end
