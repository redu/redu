class AnnotationsController < BaseController
	load_and_authorize_resource

  def create
    if @annotation.save
      #flash.now[:notice] = "Anotação salva!"
      respond_to do |format|
        format.js
      end
    else
      flash.now[:error] = "Ocorreu uma falha ao salvar a anotação."
      respond_to do |format|
        format.js
      end
    end
  end

  def update
    
    respond_to do |format|
      if @annotation.update_attributes(params[:annotation])

        format.html {
          flash[:notice] = 'Anotações atualizadas para esta aula'
          redirect_to(@annotation) }
          format.xml  { head :ok }
          format.js { render :action => "create" }
      else
        flash.now[:error] = "Ocorreu uma falha ao atualizar a anotação."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @annotation.errors, :status => :unprocessable_entity }
        format.js   { render :action => "create" }
      end
    end
  end
end
