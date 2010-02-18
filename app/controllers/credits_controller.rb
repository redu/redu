class CreditsController < BaseController
  def index
    @balance = 10
    
    @credit = Credit.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end
  def show
    @credit = Credit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end
  
  def create
    @credit = Credit.new(params[:credit])
    @credit.user_id = current_user
    

    respond_to do |format|
      if @credit.save
        flash[:notice] = 'Credito comprado com sucesso'
        format.html { redirect_to(@credit) }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
