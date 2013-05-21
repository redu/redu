# -*- encoding : utf-8 -*-
class SolrProfileIndexerObserver < ActiveRecord::Observer
  # Observer responsável pela indexação de User

  observe :user, :experience, :education

  def after_save(object)
    user_for(object).index!
  end

  def after_destroy(object)
    user_for(object).index!
  end

  private

  def user_for(record)
    klass = record.class.to_s
    if klass == "User"
      record
    elsif klass == "Education" || klass == "Experience"
      record.user
    end
  end
end
