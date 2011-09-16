class StatusesController < BaseController

  load_and_authorize_resource :status, :except => [:index]

  def create
    @status = Activity.new(params[:status])

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
    @status = Answer.new(params[:status])
    @status.in_response_to = responds_to
    @status.user = current_user
    @status.save

    respond_to do |format|
      if @status.save
        format.html { redirect_to :back }
        format.js
      else
        format.html {
          flash[:statuses_errors] = @status.errors.full_messages.to_sentence
          redirect_to :back
        }
        format.js { render :template => 'statuses/errors', :locals => { :status => @status } }
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
