module Api
  class SubjectsController < Api::ApiController

    # GET /api/spaces/:space_id/subjects
    def index
      @space = Space.find(params[:space_id])
      authorize! :read, @space
      @subjects = @space.try(:subjects) || []
      respond_with(:api, @subjects)
    end

    # GET /api/subjects/:subject_id
    def show
      @subject = Subject.find(params[:id])
      authorize! :read, @subject
      respond_with(@subject)
    end

    # POST /api/spaces/:space_id/subjects
    def create
      @space = Space.find(params[:space_id])
      @subject = @space.subjects.create(params[:subject]) do |s|
        authorize! :create, s
        s.owner = current_user
        s.space = @space
      end

      if @subject.valid?
        @subject.update_attribute(:finalized, true)
        @subject.create_enrollment_associations
        @subject.notify_subject_added
      end

      respond_with(:api, @subject)
    end

    def destroy
      @subject = Subject.find(params[:id])
      authorize! :destroy, @subject
      @subject.destroy
      respond_with(@subject)
    end

    # GET /api/subject/subject_id/enrollments
    def users_enrolled
      @subject = Subject.find(params[:subject_id])
      authorize! :read, @subject
      @users = @subject.enrollments.collect { |u| User.find(u.user_id) }
      respond_with(:api, @users)
    end

  end
end
