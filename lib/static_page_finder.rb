class StaticPageFinder
  # Infere nome do template e layout baseado no :page_id passado.
  #
  # Assumindo a seguinte estrutura de diretório:
  #
  #   app/views/pages/
  #   └── basic
  #       ├── authoring
  #       │   ├── _benefits.html.erb
  #       │   ├── _introduction.html.erb
  #       │   ├── _projects.html.erb
  #       │   └── _title.html.erb
  #       └── authoring.html.erb
  #
  # Ao inicializar o StaticPageFinder com :page_id => 'authoring', o layout
  # inferido será 'basic' e o template 'pages/basic/authoring'. Tais informações
  # podem ser utilizadas no controlador da seguinte forma:
  #
  #   page_finder = StaticPageFinder.new(:page_id => 'authoring')
  #   render :template => page_finder.template, :layout => page_finder.layout
  #
  VALID_CHARACTERS = "_a-zA-Z0-9-".freeze

  def initialize(opts={})
    @page_id = opts[:page_id]
    @view_dir = opts[:view_dir] || "pages"
    @content_path = opts[:content_path] || Rails.root.join("app", "views", view_dir)
  end

  # Caminho para o template
  def template
    return "#{view_dir}/#{view_name}" if possible_templates.empty?
    "#{view_dir}/#{layout}/#{view_name}"
  end

  # Nome do layout
  def layout
    return nil if possible_templates.empty?
    File.dirname(possible_templates.first).split('/').last
  end

  protected

  attr_reader :view_dir, :content_path, :page_id

  # page_id sem caracteres especiais
  def view_name
    page_id.tr("^#{VALID_CHARACTERS}", '')
  end

  # Retorna paths dos templates começando com view_name
  def possible_templates
    Pathname.glob("#{content_path}/*/#{view_name}*").select do |name|
      File.file?(name)
    end
  end
end
