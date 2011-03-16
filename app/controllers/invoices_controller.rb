class InvoicesController < BaseController
  load_and_authorize_resource :plan
  load_and_authorize_resource :invoice, :through => :plan

  def index
    @user = @plan.user
    @invoices = @plan.invoices
    @invoices = @invoices.pending if params.fetch(:pending, false)
    @quota = @plan.billable.quota

    # Quoatas
    @quota_multimedia =  ( @quota.multimedia * 100.0 ) / @plan.video_storage_limit
    @quota_file =  (@quota.files * 100.0) / @plan.file_storage_limit
    @quota_members =  (@plan.billable.users.count * 100.0) / @plan.members_limit

    respond_to do |format|
      format.html do
        render :template => "invoices/new/index", :layout => "new/application"
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

end
