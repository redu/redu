class EventsController < BaseController
  layout 'new_application'

  require 'htmlentities'
  caches_page :ical
  cache_sweeper :event_sweeper, :only => [:create, :update, :destroy]
 
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

  before_filter :admin_required, :except => [:index, :show, :ical]

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
  end

  def index  
    @events = Event.upcoming.paginate(:include => :owner, 
      :page => params[:page], 
      :order => 'start_time DESC', 
      :per_page => AppConfig.items_per_page)
  end

  def past
    @events = Event.past.find(:all, :page => {:current => params[:page]})
    render :template => 'events/index'
  end

  def new
    @event = Event.new(params[:event])
  end
  
  def edit
    @event = Event.find(params[:id])
  end
    
  def create
    @event = Event.new(params[:event])
    @event.owner = current_user

    respond_to do |format|
      if @event.save
        flash[:notice] = :event_was_successfully_created.l
        
        format.html { redirect_to event_path(@event) }
      else
        format.html { 
          render :action => "new"
        }
      end
    end    
  end

  def update
    @event = Event.find(params[:id])
        
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to event_path(@event) }
      else
        format.html { 
          render :action => "edit"
        }
      end
    end
  end
  
  # DELETE /homepage_features/1
  # DELETE /homepage_features/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
end
