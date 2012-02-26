class FoldersController < BaseController
  load_and_authorize_resource :space
  load_and_authorize_resource :folder,
    :through => :space

  before_filter :load_course_and_environment

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.js { render :error_quota }
    end
  end

  # FILE
  def destroy_file
    @myfile = Myfile.find(params[:file_id], :include => :folder)

    @folder_id = @myfile.folder.id
    @space_id = @myfile.folder.space_id

    respond_to do |format|
      if @myfile.destroy
        @space.course.quota.try(:refresh!)
        @space.course.environment.quota.try(:refresh!)

        format.html do
          flash[:notice] = 'Arquivo removido!'
          redirect_to space_folders_path(:id => @folder_id, :space_id => @space_id)
        end
        format.js do
            list
            render :partial => 'folders/index'
        end
      else
        format.html {
          flash[:error] = @myfile.errors.full_messages.join(", ")
          redirect_to space_folders_path(:id => @folder_id, :space_id => @space_id)
        }
        format.js do
          render :update do |page|
            # update the page with an error message
          end
        end
      end
    end

  end

  # Upload the file and create a record in the database.
  # The file will be stored in the 'current' folder.
  def do_the_upload
    @myfile = Myfile.new(params[:myfile])
    @myfile.user = current_user

    authorize! :upload_file, @myfile

    respond_to do |format|
      if @myfile.save
        @space.course.quota.try(:refresh!)
        @space.course.environment.quota.try(:refresh!)
        format.html { redirect_to @space }
        format.js do
          list
          render :do_the_upload
        end
      else
        format.html { redirect_to @space }
        format.js do
          list
          render :do_the_upload
        end
      end
    end
  end

  def download
    @myfile = Myfile.find(params[:file_id])

    if  @myfile
        # Gerando uma url do s3 com o timeout de 20 segundos
        # O usuário deve COMEÇAR a baixar dentro desse tempo.
        if Rails.env == "production" || Rails.env == "staging"
          redirect_to @myfile.attachment.expiring_url(20) and return false
        end

        send_file @myfile.attachment.path, :type=> @myfile.attachment.content_type
    else
        flash[:notice] = "Você não tem permissão para baixar o arquivo."
        redirect_to user_path(current_user)
    end
  end

  # FOLDER
  # The default action, redirects to list.
  def index
    list(params[:id])

    respond_to do |format|
      format.html
      format.js { render :partial => "folders/index" }
    end
  end


  # Create a new folder with the posted variables from the 'new' view.
  def create
    if request.post?
      @folder = Folder.new(params[:folder])
      @folder.date_modified = Time.now
      @folder.user = current_user

      respond_to do |format|
        if @folder.save
          params[:space_id] = params[:folder][:space_id]
          list(@folder.id)
          # back to the list
          format.html {
            flash[:notice] = 'Diretório criado!'
            redirect_to space_folders_path(:space_id => params[:folder][:space_id], :id => @folder.parent.id)
          }
          format.js { render :partial => "folders/index" }
        else
          format.html {
            flash[:error] = 'Não foi possível criar o diretório'
            redirect_to space_folders_path(@space, @folder.parent)
          }
          format.js
        end
      end
    end
  end

  # Update the folder attributes with the posted variables from the 'rename' view.
  def update
    if @folder.update_attributes(:name => params[:folder][:name], :date_modified => Time.now)
      respond_to do |format|
        # back to the list
        format.js {
          params[:id] = @folder.parent_id
          list
        }
      end
    end
  end

  # Delete a folder.
  def destroy_folder
    @parent_id = @folder.parent_id
    @space_id = @folder.space_id
    @folder.destroy
    @space.course.quota.try(:refresh!)
    @space.course.environment.quota.try(:refresh!)
    respond_to do |format|
      # back to the list
      format.js {
        list @folder.parent_id
      }
    end

  end

  private

  # List the files and sub-folders in a folder.
  def list(id=nil)
    # Get the folder
    if id
      @folder = Folder.find(id)
    else
      @folder = @space.root_folder
      @folder = @myfile.folder if @myfile
    end

    @myfile ||= Myfile.new

    # Set if the user is allowed to update or delete in this folder;
    # these instance variables are used in the view.
    @can_update = @folder.can_be_updated_by(current_user, @space)
    @can_delete = @folder.can_be_deleted_by(current_user, @space)

    # determine the order in which files are shown
    file_order = 'attachment_file_name '
    if params[:order_by]
      file_order = params[:order_by].sub('name', 'attachment_file_name') + ' ' if params[:order_by] == 'name'
      file_order = params[:order_by].sub('filesize', 'attachment_file_size') + ' ' if params[:order_by] == 'filesize'
      file_order = params[:order_by].sub('date_modified', 'attachment_updated_at') + ' ' if params[:order_by] == 'date_modified'
    end
    file_order += params[:order] if params[:order]

    # determine the order in which folders are shown
    folder_order = 'name '
    if params[:order_by] and params[:order_by] != 'filesize'
      folder_order = params[:order_by] + ' '
      folder_order += params[:order] if params[:order]
    end

    @files_count = Myfile.includes(:folder).where('folders.space_id' => @space.id).count
    bytes = Myfile.includes(:folder).where('folders.space_id' => @space.id).
      sum(:attachment_file_size)
    @total_size = "%0.2f" % (bytes / (1024.0 * 1024));
    gigabytes = 2
    @use_percentage = "%0.2f" % (bytes / ( gigabytes * 1024.0 * 1024.0 * 1024.0))

    # List of subfolders
    @folders = @folder.list_subfolders(current_user, folder_order.rstrip)

    # List of files in the folder
    @myfiles = @folder.list_files(current_user, file_order.rstrip)
  end

  def load_course_and_environment
    @course = @space.course
    @environment = @course.environment
  end
end
