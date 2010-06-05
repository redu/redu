class FavoritesController < BaseController
  before_filter :login_required
  
  
  def favorite
    @favorite = current_user.add_favorite(params[:type], params[:id] )
    
    msg_ok, msg_err = ''
    case params[:type]
      when 'Course'
        msg_ok = "Aula adicionada ao seus favoritos!"
        msg_err = "Aula não foi adicionada ao seus favoritos"
      when 'Exam'
        msg_ok = "Exame adicionado ao seus favoritos!"
        msg_err = "Exame não foi adicionado ao seus favoritos"
      when 'Resource'
        msg_ok = "Material adicionado ao seus favoritos!"
        msg_err = "Material não foi adicionado ao seus favoritos"
      else
        msg_ok = "Recurso adicionado ao seus favoritos!"
        msg_err = "Recurso não foi adicionado ao seus favoritos"
    end
    
    if @favorite
      Log.log_activity(@favorite, 'favorite', current_user, @school)
      
      flash.now[:notice] = msg_ok
      respond_to do |format|
        format.js 
      end
    else
      flash.now[:error] = msg_err 
      
      respond_to do |format|
        format.js 
      end
    end
  end  
end
