class FavoritesController < BaseController
  before_filter :login_required
  
  
  def index
    @user = current_user#User.find(:user_id)
    respond_to do |format|
      format.js do 
        case params[:type]
          when 'exams'
             @exams = Exam.paginate(:all, 
              :joins => :favorites,
              :conditions => ["favorites.favoritable_type = 'Exam' AND favorites.user_id = ? AND exams.id = favorites.favoritable_id", current_user.id], 
              :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)
        
            
            render :update do |page|
              page.replace_html  'tabs-2-content', :partial => 'exams/exam_list'
            end
          when 'statuses'
           render :update do |page|
              
            end
        end  
      end
      format.html do 
        #@courses = Course.favorites_user_id_eq(current_user.id).descend_by_created_at
        @courses = Course.paginate(:all, 
   :joins => :favorites,
    :conditions => ["favorites.favoritable_type = 'Course' AND favorites.user_id = ? AND courses.id = favorites.favoritable_id", current_user.id], 
    :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)
        
        
      end
    end
    
  end
  
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
      else
        msg_ok = "Recurso adicionado ao seus favoritos!"
        msg_err = "Recurso não foi adicionado ao seus favoritos"
    end
    
    if @favorite
     # Log.log_activity(@favorite, 'favorite', current_user) #TODO
      
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
