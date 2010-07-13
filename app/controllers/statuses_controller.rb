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
      else
        flash[:statuses_errors] = @status.errors.full_messages.to_sentence
        format.html { redirect_to :back }
        format.xml { render :xml => @status.errors.to_xml }
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
