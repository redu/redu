class FavoritesController < BaseController

  # Não precisa de permissão, pois ele vai ver os favoritos do current_user.
  def index
    @user = current_user
    respond_to do |format|
      case params[:type]
      when 'exams'
        @exams = Exam.paginate(:all,
                               :joins => :favorites,
                               :conditions => ["favorites.favoritable_type = 'Exam' AND favorites.user_id = ? AND exams.id = favorites.favoritable_id", current_user.id],
                               :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)

        format.js do
          render :template => 'favorites/exams.rjs'
        end
      when 'statuses'
        format.js do
          #TODO
          render :template => 'favorites/statuses.rjs'
        end
      end
      format.html do
        #@lectures = Lecture.favorites_user_id_eq(current_user.id).descend_by_created_at
        @lectures = Lecture.paginate(:all,
                                   :joins => :favorites,
                                   :conditions => ["favorites.favoritable_type = 'Lecture' AND favorites.user_id = ? AND lectures.id = favorites.favoritable_id", current_user.id],
                                   :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)


      end
    end
  end

  def favorite
     if (params[:id].to_i != 0) &&
      ((params[:type].eql? 'Lecture') || (params[:type].eql? 'Exam') ||
      (params[:type].eql? 'Status'))
         favoritable = Kernel.const_get(params[:type]).find(params[:id])
     end
    authorize! :read, favoritable

    @favorite = current_user.add_favorite(params[:type], params[:id] )
    @favoritable_id = params[:id] if params[:id].to_i != 0 # Verificando para que não injetem código malicioso

    msg_ok, msg_err = ''
    case params[:type]
    when 'Lecture'
      msg_ok = "Aula adicionada ao seus favoritos!"
      msg_err = "Aula não foi adicionada ao seus favoritos"
    when 'Exam'
      msg_ok = "Exame adicionado ao seus favoritos!"
      msg_err = "Exame não foi adicionado ao seus favoritos"
    else
      msg_ok = "Recurso adicionado ao seus favoritos!"
      msg_err = "Recurso não foi adicionado ao seus favoritos"
    end

    if @favorite
      flash.now[:notice] = msg_ok
      respond_to do |format|
        if params[:type] == 'Status'
          #FIXME Tirar new_layout após todo o redesign ser feito
          if params.has_key? :new_layout
            format.js { render :template => 'favorites/new/status_favorite' }
          else
            format.js { render :template => 'favorites/status_favorite', :locals => {:favoritable_id => @favoritable_id} }
          end
        else
          format.js
        end
      end
    else
      flash.now[:error] = msg_err
      respond_to do |format|
        format.js
      end
    end
  end

  def not_favorite
     if (params[:id].to_i != 0) &&
      ((params[:type].eql? 'Lecture') || (params[:type].eql? 'Exam') ||
      (params[:type].eql? 'Status'))
         favoritable = Kernel.const_get(params[:type]).find(params[:id])
     end
    authorize! :read, favoritable

    @favorite = current_user.rm_favorite(params[:type], params[:id] )
    @favoritable_id = params[:id] if params[:id].to_i != 0 # Verificando para que não injetem código malicioso

    msg_ok, msg_err = ''
    case params[:type]
    when 'Lecture'
      msg_ok = "Aula adicionada ao seus favoritos!"
      msg_err = "Aula não foi adicionada ao seus favoritos"
    when 'Exam'
      msg_ok = "Exame adicionado ao seus favoritos!"
      msg_err = "Exame não foi adicionado ao seus favoritos"
    else
      msg_ok = "Recurso adicionado ao seus favoritos!"
      msg_err = "Recurso não foi adicionado ao seus favoritos"
    end

    if @favorite
      flash.now[:notice] = msg_ok
      respond_to do |format|
        if params[:type] == 'Status'
          #FIXME Tirar new_layout após todo o redesign ser feito
          if params.has_key? :new_layout
            format.js { render :template => 'favorites/new/status_not_favorite' }
          else
          format.js { render :template => 'favorites/status_not_favorite', :locals => {:favoritable_id => @favoritable_id} }
          end
        else
          format.js
        end
      end
    else
      flash.now[:error] = msg_err
      respond_to do |format|
        format.js
      end
    end
  end
end
