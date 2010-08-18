class AdminController < BaseController
  before_filter :admin_required
  
  ###################
  #  MODERAÇÃO
  ###################
  
  def search_users
    if params[:search_user].empty?
      @users = User.all
    else
      qry = params[:search_user] + '%'
      @users = User.all(:conditions => ["first_name LIKE ? OR last_name LIKE ? OR login LIKE ?", qry,qry,qry ])
    end
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'user_list', :partial => 'admin/user_list', :locals => {:users => @users}
        end
      end
    end
  end
  
   def moderate_school
     @removed_schools = School.all(:conditions => ["id IN (?)", params[:schools].join(',')]) unless params[:schools].empty?
    
    School.update_all("removed = 1", "id IN (?)", params[:schools].join(', '))
    
    for school in @removed_schools # TODO fazer um remove all?
       UserNotifier.deliver_remove_school(school) # TODO fazer isso em batch
       #course.destroy #TODO fazer isso automaticamente após 30 dias
    end
   flash[:notice] = 'Redes moderadas!'
   redirect_to admin_moderate_schools_path
   
 end
  
  
  def moderate_exams
     @removed_exams = Exam.all(:conditions => ["id IN (?)", params[:exams].join(',')]) unless params[:exams].empty?
    
    Exam.update_all("removed = 1", "id IN (?)", params[:exams].join(', '))
    
    for exam in @removed_exams # TODO fazer um remove all?
       UserNotifier.deliver_remove_exam(exam) # TODO fazer isso em batch
       #course.destroy #TODO fazer isso automaticamente após 30 dias
    end
   flash[:notice] = 'Exames moderados!'
   redirect_to admin_moderate_exams_path
   
 end
  
  def moderate_users
    
    case params[:submission_type]
      
      when '0' # remove selected
      @removed_users = User.all(:conditions => ["id IN (?)", params[:users].join(',')]) unless params[:users].empty?
      
      User.update_all("removed = 1", "id IN (?)", params[:users].join(', '))
      
      for user in @removed_users # TODO fazer um remove all?
        UserNotifier.deliver_remove_user(user) # TODO fazer isso em batch
        #course.destroy #TODO fazer isso automaticamente após 30 dias
      end
      when '1' # moderate roles
        User.update_all(["role_id = ?", params[:role_id]], [ "id IN (?)", params[:users].join(', ')]) if params[:role_id]
        # TODO enviar emails para usuários dizendo que foram promovidos.
    end
    flash[:notice] = 'Usuários moderados!'
    redirect_to admin_moderate_users_path
   
 end
 
  
  def moderate_courses
    @removed_courses = Course.all(:conditions => ["id IN (?)", params[:courses]]) #unless params[:courses].empty?
    
    Course.update_all("removed = 1", ["id IN (?)", params[:courses]])
    
    for course in @removed_courses 
      UserNotifier.deliver_remove_course(course) # TODO fazer isso em batch
       #course.destroy #TODO fazer isso automaticamente após 30 dias
    end
   flash[:notice] = 'Aulas removidas!'
   redirect_to admin_moderate_courses_path
   
  end
 
 
  def moderate_submissions
    approved = params[:course].reject{|k,v| v == 'reject'}
    rejected = params[:course].reject{|k,v| v == 'approve'}

    Course.update_all("state = 'approved'", :id => approved.keys)
    Course.update_all("state = 'rejected'", :id => rejected.keys)

    flash[:notice] = 'Aulas moderadas!'
    redirect_to admin_dashboard_submissions_path
  end
  
  
  def approve
    @course = Course.find(params[:id])
    @course.approve!
    
    # Só para efeitos de teste. O objeto school vai ser passado na criação das aulas quando estiver
    # dentro de uma rede.
    #@school = School.find(:first, :conditions => ["owner = ?", current_user.id])
    
    Log.log_activity(@course, 'create', @course.owner, @school)
    
    flash[:notice] = 'A aula foi aprovada!'
    redirect_to admin_moderate_submissions_path
  end
  
  def disapprove
    @course = Course.find(params[:id])
    @course.reject!
    flash[:notice] = 'A aula foi rejeitada!'
    redirect_to admin_moderate_submissions_path
  end
  
  
  # LISTAGENS
  # lista pendendes para MODERAÇÃO da administração do Redu
  def submissions
    @courses = Course.paginate(:conditions => ["public = 1 AND published = 1 AND state LIKE 'waiting'"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at ASC', 
      :per_page => 20)
    
    respond_to do |format|
      format.html 
    end
    
  end
  
  def courses
    @courses = Course.paginate(:conditions => ["public = 1 AND published = 1 AND removed = 0"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'created_at DESC', 
      :per_page => 20)
    
    respond_to do |format|
      format.html
    end
  end
  
  
    def exams
    @exams = Exam.paginate(:conditions => ["public = 1 AND published = 1 AND removed = 0"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'created_at DESC', 
      :per_page => 20)
    
    respond_to do |format|
      format.html 
    end
  end
  
  
    def schools
    @schools = School.paginate(:conditions => ["public = 1 AND removed = 0"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'created_at DESC', 
      :per_page => 20)
    
    respond_to do |format|
      format.html 
    end
  end
  
  
    def users
    @users = User.paginate(:conditions => ["removed = 0"],
      :page => params[:page], 
      :order => 'created_at DESC', 
      :per_page => 20)
    
    respond_to do |format|
      format.html 
    end
  end
  
  
  
  #
  #
  
  def contests
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contests.to_xml }
    end    
  end

  def events
    @events = Event.find(:all, :order => 'start_time DESC', :page => {:current => params[:page]})
  end
  
  def messages
    @user = current_user
    @messages = Message.find(:all, :page => {:current => params[:page], :size => 50}, :order => 'created_at DESC')
  end
  
#  def users
#    cond = Caboose::EZ::Condition.new
#    if params['login']    
#      cond.login =~ "%#{params['login']}%"
#    end
#    if params['email']
#      cond.email =~ "%#{params['email']}%"
#    end        
#    
#    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
#  end
  
  def comments
    @comments = Comment.find(:all, :page => {:current => params[:page], :size => 100}, :order => 'created_at DESC')
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = :the_user_was_activated.l
    redirect_to :action => :users
  end
  
  def deactivate_user
    user = User.find(params[:id])
    user.deactivate
    flash[:notice] = "The user was deactivated".l
    redirect_to :action => :users
  end  
  
end
