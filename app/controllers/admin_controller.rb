class AdminController < BaseController
  before_filter :admin_required

  def search_users
    if params[:search_user].empty?
      @users = User.all
    else
      qry = params[:search_user] + '%'
      @users = User.all(:conditions => ["first_name LIKE ? OR last_name LIKE ? OR login LIKE ?", qry,qry,qry ])
    end
    respond_to do |format|
      format.js
    end
  end

  def moderate_space
    @removed_spaces = Space.all(:conditions => ["id IN (?)", params[:spaces].join(',')]) unless params[:spaces].empty?

    Space.update_all("removed = 1", "id IN (?)", params[:spaces].join(', '))

    for space in @removed_spaces # TODO fazer um remove all?
      UserNotifier.deliver_remove_space(space) # TODO fazer isso em batch
      #lecture.destroy #TODO fazer isso automaticamente após 30 dias
    end
    flash[:notice] = 'Redes moderadas!'
    redirect_to admin_moderate_spaces_path
  end

  def moderate_exams
    @removed_exams = Exam.all(:conditions => ["id IN (?)", params[:exams].join(',')]) unless params[:exams].empty?

    Exam.update_all("removed = 1", "id IN (?)", params[:exams].join(', '))

    for exam in @removed_exams # TODO fazer um remove all?
      UserNotifier.deliver_remove_exam(exam) # TODO fazer isso em batch
      #lecture.destroy #TODO fazer isso automaticamente após 30 dias
    end
    flash[:notice] = 'Exames moderados!'
    redirect_to admin_moderate_exams_path
  end

  def moderate_users
    case params[:submission_type]
    when '0' # remove selected
      @removed_users = User.find(params[:users]) unless params[:users].empty?

      # Desta forma os status vão permanecer mesmo depois do usuário ser "removido", pois as dependências dele
      # só serão deletadas quando ele for realmente deletado.
      #User.update_all("removed = 1", :id => params[:users].join(', '))
      for user in @removed_users # TODO fazer um remove all?
        user.destroy
        UserNotifier.deliver_remove_user(user) # TODO fazer isso em batch
        #lecture.destroy #TODO fazer isso automaticamente após 30 dias
      end
    when '1' # moderate roles
      User.update_all(["role_id = ?", params[:role_id]], [:id => params[:users].join(', ')]) if params[:role_id]
      # TODO enviar emails para usuários dizendo que foram promovidos.
    end
    flash[:notice] = 'Usuários moderados!'
    redirect_to admin_moderate_users_path
  end

  def moderate_lectures
    @removed_lectures = Lecture.all(:conditions => ["id IN (?)", params[:lectures]]) #unless params[:lectures].empty?

    Lecture.update_all("removed = 1", ["id IN (?)", params[:lectures]])

    for lecture in @removed_lectures
      UserNotifier.deliver_remove_lecture(lecture) # TODO fazer isso em batch
      #lecture.destroy #TODO fazer isso automaticamente após 30 dias
    end
    flash[:notice] = 'Aulas removidas!'
    redirect_to admin_moderate_lectures_path
  end

  # LISTAGENS
  def lectures
    @lectures = Lecture.paginate(:conditions => ["published = 1 AND removed = 0"],
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

  def spaces
    @spaces = Space.paginate(:conditions => ["public = 1 AND removed = 0"],
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
