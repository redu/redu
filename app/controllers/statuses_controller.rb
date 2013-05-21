# -*- encoding : utf-8 -*-
class StatusesController < BaseController

  load_and_authorize_resource :status, :except => [:index]

  def create
    @status = Status.new(params[:status]) do |s|
      s.user = current_user
      s.type = params[:status].fetch(:type, 'Activity').camelize
    end

    # A chamada do becomes não preveserva nested attributes não persistidos
    # no banco de dados, logo, estes devem ser carregados separadamente.
    resources = @status.status_resources
    @status = @status.becomes(@status.type.constantize)
    @status.status_resources = resources

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
    respond_to do |format|
      format.js
    end
  end

end
