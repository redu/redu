class SubjectsController < BaseController

  layout 'new_application'
  before_filter :login_required
 

  def index
    session[:subject_step] = session[:subject_params]= session[:subject_aulas]= session[:subject_id]= session[:subject_exames]  = nil
    
    if params[:school_id].nil?
    @subjects = Subject.find(:all, :conditions => "is_public like true") 
   else
     @subjects = current_user.schools.find(params[:school_id]).subjects#.paginate(paginating_params)
   end
   
   
    respond_to do |format|
     format.html # index.html.erb

     format.js  do     
       render :update do |page|
         page.replace_html  'content_list', :partial => 'subjects/school/subject_list/'
         page << "$('#spinner').hide()"
       end
     end  
     
   end
   
 end
  

  def show
    
      @subject = Subject.find(:first, :conditions => "is_public like true AND id =#{params[:id].to_i}")
     respond_to do |format|    
         if current_user.enrollments.detect{|e| e.subject_id.eql?(params[:id].to_i)}.nil?
         format.html
         else
          format.html{  render :action => "classes" }
         end
     end
     
  end

  def new
    session[:subject_params] ||= {}
    @subject = Subject.new
  end

  def create
    session[:subject_params].deep_merge!(params[:subject]) if params[:subject]
    session[:subject_aulas]= params[:aulas] unless params[:aulas].nil?
    session[:subject_exames] = params[:exams] unless params[:exams].nil?
    
    @subject = current_user.subjects.new(session[:subject_params])
    @subject.current_step = session[:subject_step]
    if  @subject.valid?
      if params[:back_button]
        @subject.previous_step
      elsif @subject.last_step?
        
        if @subject.all_valid?
          @subject.save
          @subject.create_course_subject_type_course(session[:subject_aulas], @subject.id, current_user) unless session[:subject_aulas].nil?
          @subject.create_course_subject_type_exam(session[:subject_exames], @subject.id, current_user) unless session[:subject_exames].nil?
        end
      else
        @subject.next_step
      end
      session[:subject_step]= @subject.current_step
    end

    if @subject.new_record?
      render "new"
    else
      session[:subject_step] = session[:subject_params]= session[:subject_aulas]=session[:subject_exames] = nil
       redirect_to :action =>"admin_subjects"
    end
  end


  def edit
    session[:subject_params] ||= {}
    @subject = current_user.subjects.find(params[:id])
  end
 
  def update 
    updated = false 
    session[:subject_params].deep_merge!(params[:subject]) if params[:subject]
    session[:subject_aulas]= params[:aulas] unless params[:aulas].nil?
    session[:subject_id]= params[:id] unless params[:id].nil?
    session[:subject_exames] = params[:exams] unless params[:exams].nil?

    @subject = current_user.subjects.new(session[:subject_params])
    @subject.current_step = session[:subject_step]

    if  @subject.valid?
      if params[:back_button]
        @subject.previous_step
      elsif @subject.last_step?

        if @subject.all_valid?
          @subject = current_user.subjects.find(session[:subject_id])
          @subject.update_attributes(session[:subject_params])
          @subject.course_subjects.destroy_all
          @subject.create_course_subject_type_course(session[:subject_aulas], @subject.id,current_user) unless session[:subject_aulas].nil?
          @subject.create_course_subject_type_exam(session[:subject_exames], @subject.id, current_user) unless session[:subject_exames].nil?
        end
          updated = true
      else
        @subject.next_step
      end
      session[:subject_step]= @subject.current_step
    end

    unless updated
      render "edit"
    else
      flash[:notice] = "Atualizado com sucesso!"
      session[:subject_step] = session[:subject_params]= session[:subject_aulas]= session[:subject_exames]= session[:subject_id] = nil
      redirect_to :action =>"admin_subjects"
    end

  end
 
  def destroy
    subject = current_user.subjects.find(params[:id].to_i)
    subject.destroy
    redirect_to :action =>"admin_subjects"
  end

  def classes
    Enrollment.create_enrollment(params[:id], current_user)
    @subject = Subject.find(:first, :conditions => "is_public like true AND id =#{params[:id].to_i}")
  end
  
  def admin_subjects
    @subjects = current_user.subjects
  end
  
  def admin_show
    @subject = current_user.subjects.find(params[:id])
    
  end
  
 
    

end
