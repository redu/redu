class StatusesController < BaseController

  load_and_authorize_resource :status, :except => [:more]

  def create
    @status = Status.new(params[:status])

    @status.user = current_user

    respond_to do |format|
      if @status.save
        format.html { redirect_to :back }
        format.xml { render :xml => @status.to_xml }
        format.js
      else
        format.html {
          flash[:statuses_errors] = @status.errors.full_messages.to_sentence
          redirect_to :back
        }
        format.xml { render :xml => @status.errors.to_xml }
        format.js { render :template => 'statuses/errors', :locals => { :status => @status } }
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
    when 'space'
      @statusable = Space.find(params[:id])
    when 'subject'
      @statusable = Subject.find(params[:id])
    end

    authorize! :read, @statusable

    @statuses = @statusable.recent_activity(params[:offset], params[:limit])
    respond_to do |format|
      if @statuses.length < params[:limit].to_i
        format.js { render :template => 'statuses/statuses_end', :locals => { :statusable => @statusable } }
      else
        format.js { render :template => 'statuses/statuses_more', :locals => { :statusable_id => @statusable.id } }
      end
    end
  end

  def destroy
    #TODO
  end

end
