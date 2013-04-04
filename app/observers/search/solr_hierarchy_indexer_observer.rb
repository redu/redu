class SolrHierarchyIndexerObserver < ActiveRecord::Observer
  # Observer responsável pela indexação de Environment, Course e Space

  observe :environment, :course, :space

  def after_save(object)
    object.index!
  end

  def after_destroy(object)
    object.index!
  end
end
