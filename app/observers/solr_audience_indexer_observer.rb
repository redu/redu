class SolrAudienceIndexerObserver < ActiveRecord::Observer
  # Observer de Audience que reindexa o curso associado a essa entidade após
  # modificação / destruição

  observe :audience

  def after_save(object)
    object.course.index!
  end

  def after_destroy(object)
    object.course.index!
  end
end
