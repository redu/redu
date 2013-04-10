class MyfileService < StoredContentService
  def initialize(options={})
    super options.merge(:model_class => Myfile)
  end

  # Sobrescreve create por causa de autorização específica.
  def create(&block)
    refresh! { super }
    model
  end

  protected

  def infered_quota
    if model && model.folder
      model.folder.space.course.quota || model.folder.space.course.environment.quota
    end
  end
end
