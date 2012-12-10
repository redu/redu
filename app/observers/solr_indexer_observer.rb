class SolrIndexerObserver < ActiveRecord::Observer
  # Observer responsável pela indexação de User, Environment, Course e Space

  observe :user, :experience, :education, :high_school,
    :higher_education, :complementary_course, :event_education, :environment,
    :course, :space, :audience

  def after_save(object)
    klass = object.class.to_s
    if ["Environment", "Course", "Space"].include?(klass)
      object.index!
    elsif klass == "Audience"
      object.course.index!
    else
      user_for(object).index!
    end
  end

  def after_destroy(object)
    klass = object.class.to_s
    if ["Environment", "Course", "Space"].include?(klass)
      object.index!
    elsif klass == "Audience"
      object.course.index!
    else
      user_for(object).index!
    end
  end

  private

  def user_for(record)
    klass = record.class.to_s
    if klass == "User"
      record
    elsif klass == "Education" || klass == "Experience"
      record.user
    elsif klass == "HighSchool" || klass == "HigherEducation" ||
                   klass == "ComplementaryCourse" || klass == "EventEducation"
      record.education.user
    end
  end
end
