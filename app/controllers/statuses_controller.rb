class StatusesController < BaseController
  layout 'new_application'
  before_filter :login_required

  def create
      @status = Status.new(params[:status])
      @status.user = current_user

      respond_to do |format|
        if @status.save
          format.html { redirect_to :back }
          format.xml { render :xml => @status.to_xml }
          format.js {
          render :update do |page|
            test = escape_javascript(render(:partial =>"statuses/type_proxy", :locals => {:type_proxy_counter => nil, :status => @status, :statusable => @status.statusable} ))
            page << "$('.activities').prepend('"+test+"')"
            page << "$('.status_spinner').hide()"
            page << "$('#status_text').val('')"
            page << "$('.answer').val('')"
            #TODO com jquery 1.4 pode-se usar a funcao unwrap
            page << "$('textarea.status:visible').parents('div.fieldWithErrors:first').removeClass('fieldWithErrors')"
            page << "$('.errorMessageField').remove()"
          end
          }
        else
          format.html { 
            flash[:statuses_errors] = @status.errors.full_messages.to_sentence
            redirect_to :back 
          }
          format.xml { render :xml => @status.errors.to_xml }
          format.js {
          render :update do |page|
            page << "$('.status_spinner').hide()"
            page << "$('.errorMessageField').remove()"
            page << "$('textarea.status:visible').wrap(\"<div class='fieldWithErrors'></div>\")" + \
                    ".after(\"<p class='errorMessageField'>#{@status.errors.full_messages.to_sentence}</p>\")"
          end
          }
        end
      end
    end

  def respond
    responds_to = Status.find(params[:id])
    
    @status = Status.new(params[:status])
    @status.in_response_to = responds_to
    @status.user = current_user
    
    respond_to do |format|
      if @status.save
        flash[:notice] = "Atividade enviada com sucesso" 
      end
        format.js
    end      
  end
  
  def more
    case params[:type]
      when 'user'
        @statusable = User.find(params[:id])
      when 'school'
        @statusable = School.find(params[:id])
    end
    
    @statuses = @statusable.recent_activity(params[:limit])
    new_limit = params[:limit].to_i * 10
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('.activities').append('"+escape_javascript(render(:partial => "statuses/type_proxy", :collection => @statuses, :as => :status, :locals => {:statusable => @statusable }))+"')"
          if @statuses.length < 10
            page.replace_html "#more",  ''
          else
            page.replace_html "#more",  link_to_remote("mais ainda!", :url => {:controller => :statuses, :action => :more, :id => @statusable.id, :type => params[:type], :limit => new_limit}, :method =>:get, :loading => "$('#more').html('"+escape_javascript(image_tag('spinner.gif'))+"')")
          end
         end
      end
  end
    
    
  end
  
  def new
    @status = Status.new
  end

  def index 
    @statuses = Status.group_statuses(School.find(1))
  end

  def destroy
  end

  def show
    @status = Status.find(params[:id])
  end

end
