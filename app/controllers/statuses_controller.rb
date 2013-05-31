# -*- encoding : utf-8 -*-
class StatusesController < BaseController

  load_and_authorize_resource :status, :except => [:index, :show]

  def show
    @status = Status.find_and_include_related(params[:id].to_i)

    authorize! :read, @status

    respond_to do |format|
      format.html do
        if @status.respond_to?(:in_response_to)
          redirect_to_original_status and return
        else
          render layout: 'new_application'
        end
      end
    end
  end

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

  private

  def redirect_to_original_status
    redirect_to status_path(@status.in_response_to, anchor: "answer_#{@status.id}")
  end
end
