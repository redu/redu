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
                               :page => params[:page], :order => 'created_at DESC', :per_page => Redu::Application.config.items_per_page)

        format.js do
          render :template => 'favorites/exams.rjs'
        end
      when 'statuses'
        format.js do
          render :template => 'favorites/statuses.rjs'
        end
      end
      format.html do
        @lectures = Lecture.paginate(:all,
                                   :joins => :favorites,
                                   :conditions => ["favorites.favoritable_type = 'Lecture' AND favorites.user_id = ? AND lectures.id = favorites.favoritable_id", current_user.id],
                                   :page => params[:page], :order => 'created_at DESC', :per_page => Redu::Application.config.items_per_page)


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
        if @favorite.favoritable.class.to_s == 'Status'
          format.js { render :status_favorite }
        elsif @favorite.favoritable.class.to_s == 'Lecture'
          format.js { render :lecture_favorite }
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
        if @favorite.favoritable.class.to_s == 'Status'
          format.js { render :status_not_favorite }
        elsif @favorite.favoritable.class.to_s == 'Lecture'
          format.js { render :lecture_not_favorite }
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
