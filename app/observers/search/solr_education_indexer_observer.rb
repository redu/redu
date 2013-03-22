class SolrEducationIndexerObserver < ActiveRecord::Observer
  # Observer responsável pela indexação de User
  # após manipulação com os seus educations

  observe :high_school, :higher_education,
    :complementary_course, :event_education

  def after_update(object)
    user_for(object).index!
  end

  private

  def user_for(record)
    record.education.user
  end
end
