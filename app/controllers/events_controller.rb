class EventsController < BaseController
  layout 'new_application'

  require 'htmlentities'
  caches_page :ical
  cache_sweeper :event_sweeper, :only => [:create, :update, :destroy]
  
  before_filter :login_required 
  before_filter :is_member_required
  before_filter :can_manage_required,
                :only => [:edit, :update, :destroy]
                
 
  #These two methods make it easy to use helpers in the controller.
  #This could be put in application_controller.rb if we want to use
  #helpers in many controllers
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
  end

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])

  def ical
    @calendar = Icalendar::Calendar.new
    @calendar.custom_property('x-wr-caldesc',"#{AppConfig.community_name} #{:events.l}")
    Event.find(:all).each do |event|
      ical_event = Icalendar::Event.new
      ical_event.start = event.start_time.strftime("%Y%m%dT%H%M%S")
      ical_event.end = event.end_time.strftime("%Y%m%dT%H%M%S")
      #ical_event.summary = event.name + (event.metro_area.blank? ? '' : " (#{event.metro_area})")
      coder = HTMLEntities.new
      ical_event.description = (event.description.blank? ? '' : coder.decode(help.strip_tags(event.description).to_s) + "\n\n") + event_url(event)
      ical_event.location = event.location unless event.location.blank?
      @calendar.add ical_event
   end
   @calendar.publish
   headers['Content-Type'] = "text/calendar; charset=UTF-8"
   render :text => @calendar.to_ical, :layout => false
  end

  def show
    @event = Event.find(params[:id])
    @comments = @event.comments.find(:all, :limit => 20, :order => 'created_at DESC', :include => :user)
    @school = School.find(params[:school_id])
  end

  def index
    @events = Event.upcoming.paginate(:conditions => ["school_id = ? AND state LIKE 'approved'", School.find(params[:school_id]).id],
      :include => :owner, 
      :page => params[:page], 
      :order => 'start_time DESC', 
      :per_page => AppConfig.items_per_page)
          
    @school = School.find(params[:school_id])	
  end

  #TODO Ver um jeito de passar o school_id
  def past
    
    @events = Event.past.paginate(:conditions => ["school_id = ? AND state LIKE 'approved'", School.find(params[:school_id]).id],
      :include => :owner, 
      :page => params[:page], 
      :order => 'start_time DESC', 
      :per_page => AppConfig.items_per_page)
      
    render :template => 'events/index'
  end

  def new
    @event = Event.new(params[:event])
    @school = School.find(params[:school_id])
    
  end
  
  def edit
    @event = Event.find(params[:id])
    @school = @event.school
  end
    
  def create
    @event = Event.new(params[:event])
    @event.owner = current_user
    @event.school = School.find(params[:school_id])

    respond_to do |format|
      if @event.save
        flash[:notice] = "O evento foi criado e adicionado à rede."
        
        format.html { redirect_to school_event_path(@event.school, @event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
          format.html { render :action => "new" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def update
    @event = Event.find(params[:id])
        
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'O evento foi editado.'
        format.html { redirect_to school_event_path(@event.school, @event) }
        format.xml { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { 
          format.html { render :action => :edit }
          format.xml { render :xml => @event.errors, :status => :unprocessable_entity }
        }
      end
    end
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    respond_to do |format|
      flash[:notice] = 'O evento foi excluído.'
      format.html { redirect_to school_events_path }
    end
  end

protected
  def can_manage_required
     @event = Event.find(params[:id])
     
     current_user.can_manage?(@event, @school) ? true : access_denied
  end

  def is_member_required
    @school = School.find(params[:school_id])
    
    current_user.has_access_to(@school) ? true : access_denied
  end

end
