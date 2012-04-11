class StatusesController < BaseController

  load_and_authorize_resource :status, :except => [:index]

  def create
    @status = Status.new(params[:status])
    @status.type = params[:status][:type]

    @status.user = current_user

    if(params[:resource])
      @status_resource = StatusResource.create(params[:resource])
      @status.status_resources << @status_resource
    end

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
        format.js do
          render :template => 'statuses/errors',
            :locals => { :status => @status }
        end
      end
    end
  end

  def respond
    @answer = @status.respond(params[:status], current_user)
    @status.answers << @answer # Sem isso o teste não passa

    respond_to do |format|
      unless @answer.new_record?
        format.html { redirect_to :back }
        format.js
      else
        format.html {
          flash[:statuses_errors] = @answer.errors.full_messages.to_sentence
          redirect_to :back
        }
        format.js do
          render :template => 'statuses/errors', :locals => { :status => @answer }
        end
      end
    end
  end

  def destroy
  @status.destroy
  # Deleta as respostas do Status
  Status.destroy_all(:in_response_to_id => @status.id,
                     :in_response_to_type => 'Status')
  end

end
