class MessagesController < BaseController

  load_and_authorize_resource :user

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :index, :create, :update, :edit])

  def index
    authorize! :manage, @user
    if params[:mailbox] == "sent"
      @messages = @user.sent_messages.paginate(:all, :page => params[:page],
                                               :order =>  'created_at DESC',
                                               :per_page => AppConfig.items_per_page)

      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html  'tabs-2-content', :partial => 'sent'
          end
        end
      end
    else
      @messages = @user.received_messages.paginate(:all, :page => params[:page],
                                                   :order =>  'created_at DESC',
                                                   :per_page => AppConfig.items_per_page )

      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'tabs-1-content', :partial => 'inbox'
          end
        end

        format.html do
          # necessario para a primeira requisicao que é html
        end
      end
    end
  end

  def show
    @message = Message.read(params[:id], current_user)
    @reply = Message.new_reply(@user, @message, params)

    respond_to do |format|
      format.js do
        render :update do |page|
          if params[:mailbox] == "sent"
            page.replace_html  'tabs-2-content', :partial => 'show', :locals => {:mailbox => params[:mailbox]}
          else
            page.replace_html  'tabs-1-content', :partial => 'show', :locals => {:mailbox => params[:mailbox]}
            page.replace_html 'tabs-1-header', :partial => 'unread_messages_count'
          end
        end
      end
    end
  end

  def new
    if params[:reply_to]
      in_reply_to = Message.find_by_id(params[:reply_to])
    end
    @message = Message.new_reply(@user, in_reply_to, params)

    respond_to do |format|
      format.js { render :template => 'messages/new' }
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
        format.js { render :template => 'messages/errors', :locals => {:message => :message} }
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
            format.js { render :template => 'messages/errors', :locals => {:message => :message} }
          end
          return
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
            #page.replace_html :notice, flash[:notice]
            flash.discard
            page.replace_html  'tabs-3-content', 'mensagem enviada!'
          end
        end
      end
    end
  end

  def delete_selected
    if request.post? && current_user.id == params[:user_id] # Caso tentem burlar
      if params[:delete]
        params[:delete].each { |id|
          @message = Message.find(:first, :conditions => ["messages.id = ? AND (sender_id = ? OR recipient_id = ?)", id, @user, @user])
          @message.mark_deleted(@user) unless @message.nil?
        }
        flash[:notice] = :messages_deleted.l
      end

      redirect_to user_messages_path(@user, :mailbox => params[:mailbox])
    end
  end

  def more
    page = params[:limit].to_i/10 + 1

    if params[:mailbox] == 'sent'
      @messages = @user.sent_messages.paginate(:all, :page => page,
                                               :order =>  'created_at DESC',
                                               :per_page => AppConfig.items_per_page)
    else
      @messages = @user.received_messages.paginate(:all, :page => page,
                                                   :order =>  'created_at DESC',
                                                   :per_page => AppConfig.items_per_page)
    end

    respond_to do |format|
      if @messages.length < 10
        format.js { render :template => 'messages/messages_end' }
      else
        format.js { render :template => 'messages/messages_more' }
      end
    end
  end
end
