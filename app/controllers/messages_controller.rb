class MessagesController < BaseController
  layout 'new_application'
  
  before_filter :find_user, :except => [:auto_complete_for_username]
  before_filter :login_required
  before_filter :require_ownership_or_moderator, :except => [:auto_complete_for_username]
  
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :index])

  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_username]
  
  def auto_complete_for_username
    @users = User.find(:all, :conditions => [ 'LOWER(login) LIKE ?', '%' + (params[:message][:to]) + '%' ])
    render :inline => "<%= auto_complete_result(@users, 'login') %>"
  end
    
  def index
    if params[:mailbox] == "sent"
      @messages = @user.sent_messages.find(:all, :page => {:current => params[:page], :size => 20})
      
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html  'tabs-2-content', :partial => 'sent'
          end
        end
      end
    else
      @messages = @user.received_messages.find(:all, :page => {:current => params[:page], :size => 20})
    end
  end
  
  def show
    @message = Message.read(params[:id], current_user)
    @reply = Message.new_reply(@user, @message, params)    
  end
  
  def new
    if params[:reply_to]
      in_reply_to = Message.find_by_id(params[:reply_to])
    end
    @message = Message.new_reply(@user, in_reply_to, params)  
    
     respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html  'tabs-3-content', :partial => 'new'
          end
        end
      end
  end
  
  def create
    messages = []

    if params[:message][:to].blank?
      # If 'to' field is empty, call validations to catch other
      @message = Message.new(params[:message])        
      @message.valid?
      
      respond_to do |format|
        format.html do
          render :action => :new and return
        end
        format.js do
          render :update do |page|
            #page.replace_html  'tabs-3-content', :partial => 'new'
            page << "alert('mensagem')" #TODO
          end
        end
      end
    else
      # If 'to' field isn't empty then make sure each recipient is valid
      params[:message][:to].split(',').uniq.each do |to|
        @message = Message.new(params[:message])          
        @message.recipient = User.find_by_login(to.strip)
        @message.sender = @user
        unless @message.valid?
          respond_to do |format|
        format.html do
          render :action => :new and return
        end
        format.js do
          render :update do |page|
            page << "alert('é necessário preencher todos os campos')"# TODO notice?
          end
        end
      end
        else
          messages << @message
        end
      end
      # If all messages are valid then send messages
      messages.each {|msg| msg.save!}
      flash[:notice] = :message_sent.l
      respond_to do |format|
        format.html do
          redirect_to user_messages_path(@user) and return
        end
        format.js do
          render :update do |page|
            page.replace_html  'tabs-3-content', 'mensagem enviada!'
          end
        end
      end
     
    end
  end

  def delete_selected
    if request.post?
      if params[:delete]
        params[:delete].each { |id|
          @message = Message.find(:first, :conditions => ["messages.id = ? AND (sender_id = ? OR recipient_id = ?)", id, @user, @user])
          @message.mark_deleted(@user) unless @message.nil?
        }
        flash[:notice] = :messages_deleted.l
      end
      redirect_to user_messages_path(@user)
    end
  end
  
  private
    def find_user
      @user = User.find(params[:user_id])
    end

    def require_ownership_or_moderator
      unless admin? || moderator? || (@user && (@user.eql?(current_user)))
        redirect_to :controller => 'sessions', :action => 'new' and return false
      end
      return @user
    end    
end
