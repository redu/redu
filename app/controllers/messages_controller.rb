class MessagesController < BaseController

  load_and_authorize_resource :user
   #auto_complete_for :fruit, :name

  #def auto_complete_for_username
  #  @users = User.find(:all, :conditions => [ 'LOWER(login) LIKE ?', '%' + (params[:message][:to]) + '%' ])
  #  render :inline => "<%= auto_complete_result(@users, 'login') %>"
  #end
  
  def auto_complete_for_username
    #TODO perfomance - rails metal , selecionar apenas nome e id
    if params[:tag]
      #@users = current_user.following
       @users = User.find(:all, :select=> "id,first_name", :conditions => [ 'LOWER(first_name) LIKE ?', '%' + (params[:tag]) + '%' ], :limit=>10)
    @ab = @users.map{|u| {:key => u.first_name, :value => u.id}}
    else
      #@users = User.all(:limit=>10)
    end
  
    respond_to do |format|
     # wants.html
      format.js do
        render :json => @ab
      end
    end

  end



  def index
    authorize! :manage, @user
      @messages = @user.received_messages.paginate(:all, :page => params[:page],
                                                   :order =>  'created_at DESC',
                                                   :per_page => AppConfig.items_per_page )
      respond_to do |format|
        format.html
        format.js
      end
  end

  def index_sent
    authorize! :manage, @user
    @messages = @user.sent_messages.paginate(:all, :page => params[:page],
                                             :order =>  'created_at DESC',
                                             :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @message = Message.read(params[:id], current_user)
    @reply = Message.new_reply(@user, @message, params)

    respond_to do |format|
      format.html
    end
  end

  def new
    if params[:reply_to]
      in_reply_to = Message.find_by_id(params[:reply_to])
    end
    @message = Message.new_reply(@user, in_reply_to, params)

    respond_to do |format|
      format.html
    end
  end

  def create
    messages = []

    if params[:message][:recipient_id]
      # If 'to' field is empty, call validations to catch other
      @message = Message.new(params[:message])

      unless @message.valid?
          respond_to do |format|
            format.html do
              render :action => :new and return
            end
          end
          return
        else
          messages << @message
        end
    else
      # If 'to' field isn't empty then make sure each recipient is valid
      params[:message_to].each do |to|
        @message = Message.new(params[:message])
        @message.recipient = User.find(to)
        @message.sender = @user
        unless @message.valid?
          respond_to do |format|
            format.html do
              render :action => :new and return
            end
          end
          return
        else
          messages << @message
        end
      end
      end
      # If all messages are valid then send messages
      messages.each {|msg| msg.save!}
      flash[:notice] = :message_sent.l
      respond_to do |format|
        format.html do
          redirect_to index_sent_user_messages_path(@user) and return
        end
      end
  end

  def delete_selected
    if request.post? && current_user.id == params[:user_id].to_i # Caso tentem burlar
      if params[:delete]
        params[:delete].each { |id|
          @message = Message.find(:first, :conditions => ["messages.id = ? AND (sender_id = ? OR recipient_id = ?)", id, @user, @user])
          @message.mark_deleted(@user) unless @message.nil?
        }
        flash[:notice] = :messages_deleted.l
      end
    end

    if params[:mailbox] == 'inbox'
      redirect_to user_messages_path(@user)
    elsif params[:mailbox] == 'sent'
      redirect_to index_sent_user_messages_path(@user)
    end
  end
end
