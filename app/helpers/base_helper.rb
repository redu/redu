require 'md5'

# Methods added to this helper will be available to all templates in the application.
module BaseHelper

  # Inclui o javascript de forma lazy
  def async_include_javascripts(*packages, &block)
    tags = packages.map do |pack|
      should_package? ? Jammit.asset_url(pack, :js) : Jammit.packager.individual_urls(pack.to_sym, :js)
    end

    javascript_tag(:type => 'text/javascript') do
      result = "LazyLoad.js(#{tags.flatten.to_json}"

      if block.nil?
        result << ");"
      else
        result << ", function(){ #{capture(&block)}});"
      end

      result.html_safe
    end.html_safe
  end

  def async_include_css(*packages)
    tags = packages.map do |pack|
      should_package? ? Jammit.asset_url(pack, :css) : Jammit.packager.individual_urls(pack.to_sym, :css)
    end

    javascript_tag(:type => 'text/javascript') do
      "LazyLoad.css(#{tags.flatten.to_json});".html_safe
    end.html_safe

  end

  # Cria lista não ordenada no formato da navegação do widget de abas (jquery UI)
  def tabs_navigation(*paths)
    lis = paths.collect do |item|
      name, path, options = item
      class_name = "ui-state-active" if current_page?(path)

      content_tag :li, :class => class_name do
        link_to name, path, options
      end
    end

    lis.join("\n").html_safe
  end

  # Cria markup das abas fake a partir de uma ou mais listas do tipo
  # [nome, path, options] (mesmo parâmetros passados para o link_to)
  def fake_tabs(*paths, &block)
    locals = {
      :navigation => tabs_navigation(*paths),
      :body => capture(&block)
    }

    render(:partial => 'shared/fake_tabs', :locals => locals)
  end

  def error_for(object, method = nil, options={})
    if method
      err = instance_variable_get("@#{object}").errors[method].to_sentence rescue instance_variable_get("@#{object}").errors[method]
    else
      err = @errors["#{object}"] rescue nil
    end
    options.merge!(:class=>'errorMessageField',:id=>"#{[object,method].compact.join('_')}-error",
    :style=> (err ? "#{options[:style]}":"#{options[:style]};display: none;"))
    content_tag("p", err || "", options )
  end

  def type_class(resource)
    icons = ['3gp', 'bat', 'bmp', 'doc', 'css', 'exe', 'gif', 'jpg', 'jpeg', 'jar','zip',
             'mp3', 'mp4', 'avi', 'mpeg', 'mov', 'm4p', 'ogg', 'pdf', 'png', 'psd', 'ppt', 'txt', 'swf', 'wmv', 'xls', 'xml', 'zip']

    file_ext = resource.attachment_file_name.split('.').last if resource.attachment_file_name.split('.').length > 0
    if file_ext and icons.include? file_ext
      'ext_'+ file_ext
    else
      'ext_blank'
    end
  end


  def activity_name(item)
    link_user = link_to item.user.display_name, user_path(item.user)
    type = item.logeable_type.underscore
      case type
        when 'user'
         @activity = "acabou de entrar no redu" if item.log_action == "login"
         @activity = "atualizou seu status para: <span style='font-weight: bold;'>\"" + item.logeable_name + "\"</span>" if item.log_action == "update"

        when 'lecture'
          lecture = item.logeable
          link_obj = link_to(item.logeable_name, space_subject_lecture_path(lecture.subject.space, lecture.subject, lecture))

          @activity = "está visualizando a aula " + link_obj if item.log_action == "show"
          @activity = "criou a aula " + link_obj if item.log_action == "create"
          @activity =  "adicionou a aula " + link_obj + " ao seus favoritos" if item.log_action == "favorite"

      when 'exam'
          exam = item.logeable
          link_obj = link_to(item.logeable_name, space_subject_exam_path(exam.subject.space, exam.subject, exam))

          @activity = "acabou de responder o exame " + link_obj if item.log_action == "results"
          @activity = "está respondendo ao exame " + link_obj if item.log_action == "answer"
          @activity =  "criou o exame " + link_obj if item.log_action == "create"
          @activity =  "adicionou o exame " + link_obj + " ao seus favoritos" if item.log_action == "favorite"
      when 'space'
          link_obj = link_to(item.logeable_name, space_path(item.logeable_id))

          @activity =  "criou a disciplina " + link_obj if item.log_action == "create"
          @activity =  "adicionou a disciplina " + link_obj + " ao seus favoritos" if item.log_action == "favorite"
      when 'subject'
          link_obj = link_to(item.logeable_name, space_subject_path(item.logeable.space, item.logeable))

          @activity =  "criou o módulo " + link_obj if item.log_action == "create"
      when 'topic'
          @topic = Topic.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, space_forum_topic_path(@topic.forum.space, @topic))

          @activity = "criou o tópico " + link_obj if item.log_action == 'create'
      when 'sb_post'
          @post = SbPost.find(item.logeable_id)
          link_obj = link_to(@post.topic.title, space_forum_topic_path(@post.topic.forum.space, @post.topic))

          @activity = "respondeu ao tópico " + link_obj if item.log_action == 'create'
      when 'event'
          @event = Event.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, polymorphic_path([@event.eventable, @event]))

          @activity =  "criou o evento " + link_obj if item.log_action == "create"
      when 'bulletin'
          @bulletin = Bulletin.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, polymorphic_path([@bulletin.bulletinable, @bulletin]))

          @activity =  "criou a notícia " + link_obj if item.log_action == "create"
      when 'myfile'
        @space = item.statusable
        @myfile = item.logeable
        link_obj = link_to @myfile.attachment_file_name,
          download_space_folder_url(@space, @myfile.folder,
                                    :file_id => @myfile)
        @activity =  "adicionou o arquivo #{link_obj} a disciplina #{link_to @space.name, @space}"
      else
          @activity = " atividade? "
      end
      @activity
  end

  def forum_page?
    %w(forums topics sb_posts spaces).include?(controller.controller_name)
  end

  def block_to_partial(partial_name, html_options = {}, &block)
    concat(render(:partial => partial_name, :locals => {:body => capture(&block), :html_options => html_options}))
  end

  def truncate_chars(text, length = 30, end_string = '...')
     return if text.blank?
     (text.length > length) ? text[0..length] + end_string  : text
  end

  def truncate_words(text, length = 30, end_string = '...')
    return if text.blank?
    words = strip_tags(text).split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def truncate_words_with_highlight(text, phrase)
    t = excerpt(text, phrase)
    highlight truncate_words(t, 18), phrase
  end

  def excerpt_with_jump(text, end_string = ' ...')
    return if text.blank?
    doc = Hpricot( text )
    paragraph = doc.at("p")
    if paragraph
      paragraph.to_html + end_string
    else
      truncate_words(text, 150, end_string)
    end
  end

  def page_title
    app_base = Redu::Application.config.name
    tagline = " | #{Redu::Application.config.tagline}"

    title = app_base
    case controller.controller_name
      when 'base'
          title += tagline
                        when 'pages'
                          if @page and @page.title
                            title = @page.title + ' - ' + app_base + tagline
                          end
      when 'posts'
        if @post and @post.title
          title = @post.title + ' - ' + app_base + tagline
          title += (@post.tags.empty? ? '' : " - "+ t(:keywords) +": " + @post.tags[0...4].join(', ') )
          @canonical_url = user_post_url(@post.user, @post)
        end
      when 'users'
        if @user && !@user.new_record? && @user.login
          title = @user.login
          title += ' - ' + app_base + tagline
          @canonical_url = user_url(@user)
        else
          title = t(:showing_users) + ' - ' + app_base + tagline
        end
      when 'photos'
        if @user and @user.login
          title = @user.login + '\'s '+ t(:photos) +' - ' + app_base + tagline
        end
      when 'tags'
        case controller.action_name
          when 'show'
            title = @tags.map(&:name).join(', ') + ' '
            title += params[:type] ? params[:type].pluralize : t(:posts_photos_and_bookmarks)
            title += ' (Related: ' + @related_tags.join(', ') + ')' if @related_tags
            title += ' | ' + app_base
            @canonical_url = tag_url(URI.escape(@tags_raw, /[\/.?#]/)) if @tags_raw
          else
          title = 'Showing tags - ' + app_base + tagline
        end
      when 'categories'
        if @category and @category.name
          title = @category.name + ' '+ t(:posts_photos_and_bookmarks) +' - ' + app_base + tagline
        else
          title = t(:showing_categories) + ' - ' + app_base + tagline
        end
      when 'lectures'
      if @lecture and @lecture.name
        title = 'Aula: ' + @lecture.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Aulas' +' - ' + app_base + tagline
      end
      when 'exams'
      if @exam and @exam.name
        title = 'Exame: ' + @exam.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Exames' +' - ' + app_base + tagline
      end
      when 'spaces'
      if @space and @space.name
        title = @space.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Disciplinas' +' - ' + app_base + tagline
      end
      when 'skills'
        if @skill and @skill.name
          title = t(:find_an_expert_in) + ' ' + @skill.name + ' - ' + app_base + tagline
        else
          title = t(:find_experts) + ' - ' + app_base + tagline
        end
      when 'sessions'
        title = t(:login) + ' - ' + app_base + tagline
    end

    if @page_title
      title = @page_title + ' - ' + app_base + tagline
    elsif title == app_base
      title = t(:showing) + ' ' + controller.controller_name.capitalize + ' - ' + app_base + tagline
    end
    title.html_safe
  end

  def activities_line_graph(options = {})
    line_color = "0x628F6C"
    prefix  = ''
    postfix = ''
    start_at_zero = false
    swf = "/images/swf/line_grapher.swf?file_name=/statistics.xml;activities&line_color=#{line_color}&prefix=#{prefix}&postfix=#{postfix}&start_at_zero=#{start_at_zero}"

    code = <<-EOF
    <object width="100%" height="400">
    <param name="movie" value="#{swf}">
    <embed src="#{swf}" width="100%" height="400">
    </embed>
    </object>
    EOF
    code
  end

  def last_active
    session[:last_active] ||= Time.now.utc
  end

  def submit_tag(value = t( :save_changes ), options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>or " + or_option + "</span>" if or_option
    super
  end

  def avatar_for(user, size=32)
    image_tag user.avatar.url(:medium), :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed.png', :size => '14x14', :alt => t( :subscribe_to ) + " #{title}"), url
  end

  def search_posts_title
    returning(params[:q].blank? ? t(:recent_posts) : t(:searching_for) + " '#{h params[:q]}'") do |title|
      title << " by #{h User.find(params[:user_id]).display_name}" if params[:user_id]
      title << " in #{h Forum.find(params[:forum_id]).name}"       if params[:forum_id]
    end
  end

  def search_user_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    options[:format] = :rss if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{route_key}_sb_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? search_all_sb_posts_path(options) : send("all_#{prefix}sb_posts_path", options)
  end

  def time_ago_in_words_or_date(date)
    if date.to_date.eql?(Time.now.to_date)
      display = I18n.l(date.to_time, :format => :time_ago)
    elsif date.to_date.eql?(Time.now.to_date - 1)
      display = t(:yesterday)
    else
      display = I18n.l(date.to_date, :format => :date_ago)
    end
  end

  def owner_link
    if @space.owner
      link_to @space.owner.display_name, @space.owner
    else
      if current_user.can_be_owner? @space
        'Sem dono ' + link_to("(pegar)", take_ownership_space_path)
      else
        'Sem dono'
      end
      #TODO e se ninguem estiver apto a pegar ownership?
    end

  end

  def get_random_number
    SecureRandom.hex(4)
  end

  # Gera o nome do recurso (class_name) devidamente pluralizado de acordo com
  # a quantidade (qty)
  def resource_name(class_name, qty)
    case class_name
    when :myfile
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'arquivo').split(' ')[1]}"
    when :folder
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'arquivo').split(' ')[1]}"
    when :bulletin
        "#{qty > 1 ? "novas" : "nova"} #{pluralize(qty, 'notícia').split(' ')[1]}"
    when :event
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'evento').split(' ')[1]}"
    when :topic
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'tópico').split(' ')[1]} "
    when :subject
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'módulo').split(' ')[1]} "
    end
  end

  # Mostra tabela de preço de planos
  def pricing_table(plans=nil)
    plans ||= Plan::PLANS

    render :partial => "plans/plans", :locals => { :plans => plans }
  end

  private

  def should_package?
    Jammit.package_assets && !(Jammit.allow_debugging && params[:debug_assets])
  end

end
