class MyfileService < StoredContentService
  def initialize(options)
    super options.merge(:model_class => Myfile)
  end

  # Sobrescreve create por causa de autorização específica.
  def create(&block)
    refresh! do
      @model = build(&block)
      ability.authorize!(:upload_file, model)
      model.save
    end
    model
  end

  protected

  def infered_quota
    if model && model.folder
      model.folder.space.course.quota || model.folder.space.course.environment.quota
    end
  end

  def authorize!(myfile)
    ability.authorize!(:manage, myfile)
  end
end
