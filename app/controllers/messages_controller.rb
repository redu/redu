class MessagesController < BaseController

  load_and_authorize_resource :user

  def index
    authorize! :manage, @user
      @messages = @user.received_messages.paginate(:all, :page => params[:page],
                                                   :order =>  'created_at DESC',
                                                   :per_page => Redu::Application.config.items_per_page )
      respond_to do |format|
        format.html
        format.js
      end
  end

  def index_sent
    authorize! :manage, @user
    @messages = @user.sent_messages.paginate(:all, :page => params[:page],
                                             :order =>  'created_at DESC',
                                             :per_page => Redu::Application.config.items_per_page)
    respond_to do |format|
        format.html
        format.js
    end
  end

  def show
    authorize! :manage, @user
    @message = Message.read(params[:id], current_user)
    @reply = Message.new_reply(@user, @message, params)

    respond_to do |format|
      format.html
    end
  end

  def new
    authorize! :manage, @user
    if params[:reply_to]
      in_reply_to = Message.find_by_id(params[:reply_to])
    end
    @message = Message.new_reply(@user, in_reply_to, params)

    respond_to do |format|
      format.html
    end
  end

  def create  #TODO verificar se está enviando uma mensagem para um amigo mesmo ou se ta tentando colocar o id de outra pessoa?
    authorize! :manage, @user
    messages = []

    if params[:message][:reply_to] # resposta
      @message = Message.new(params[:message])
      @message.save!
      flash[:notice] = "Mensagem enviada!"
      respond_to do |format|
        format.html do
          redirect_to index_sent_user_messages_path(@user) and return
        end
      end
    end

     if not params[:message_to] or  params[:message_to].empty?
        flash[:error] = "Destinatários inexistentes!"
        respond_to do |format|
            format.html do
              render :template => 'messages/new' and return
            end
          end
      end


      # If 'to' field isn't empty then make sure each recipient is valid
      params[:message_to].each do |to|
        @message = Message.new(params[:message])
        @message.recipient_id = to# User.find(to)
        @message.sender = @user
        unless @message.valid?
          respond_to do |format|
            format.html do
              render :template => 'messages/new' and return
            end
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
    elsif params[:mailbox] == 'outbox'
      redirect_to index_sent_user_messages_path(@user)
    end
  end
end
