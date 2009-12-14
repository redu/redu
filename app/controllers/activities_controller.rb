class ActivitiesController < BaseController
  before_filter :login_required,  :except => [:index, :recent]
  before_filter :find_user,       :except => [:index, :destroy, :recent]
  before_filter :require_current_user,            :except => [:index, :destroy, :recent]
  before_filter :require_ownership_or_moderator,  :only   => [:destroy]  
  
  
  def network
    @activities = @user.network_activity(:size => 15, :current => params[:page])
  end
  
  def index
    @activities = User.recent_activity(:size => 30, :current => params[:page], :limit => 1000)
    @popular_tags = popular_tags(30, ' count DESC')  
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
      format.json  { render :json => @activities }
    end
  end
  
  def recent
    ''' V1
    @activities =  Activity.recent.find(:all, :limit => 1000) 
    @users = User.all(:conditions => ["id IN (?)", @activities.collect { |act| act.user_id }])
    '''
    
    @users = Array.new
    @users << current_user
    @activities =  Activity.recent.find(:all, :conditions => ["id IN (?)", current_user.follows.collect{ |flw| flw.id } ],:include => :users, :limit => 15) 
    @items = Item.find(:all, :conditions => ["id IN (?)", @activities.collect{ |itm| itm.item_id } ]) #ver item type
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => Array[@activities, @users] }
      format.json  { render :json => Array[@activities, @users] }
    end
    
  end
  
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    
    respond_to do |format|
      format.html {redirect_to :back and return}
      format.js
    end
  end
  
  private
    def require_ownership_or_moderator
      @activity = Activity.find(params[:id])  
         
      unless @activity && @activity.can_be_deleted_by?(current_user)
        redirect_to :controller => 'sessions', :action => 'new' and return false
      end
      return @user
    end

end
