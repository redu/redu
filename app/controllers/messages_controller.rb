class MessagesController < BaseController

  load_and_authorize_resource :user, :find_by => :login

  def index
    authorize! :manage, @user
    @total_messages = @user.received_messages.count
    @messages = @user.received_messages.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html do
        render :layout => 'new_application'
      end
      format.js do
        render_endless 'messages/item', @messages, '#messages > tbody',
          :partial_locals => { :mailbox => :inbox, :user => @user },
          :template => 'shared/new_endless_kaminari'
      end
    end
  end

  def index_sent
    authorize! :manage, @user
    @total_messages = @user.sent_messages.count
    @messages = @user.sent_messages.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
        format.html do
          render :layout => 'new_application'
        end
        format.js do
          render_endless 'messages/item', @messages, '#messages > tbody',
            :partial_locals => { :mailbox => :outbox, :user => @user },
            :template => 'shared/new_endless_kaminari'
        end
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
    if params[:recipient] and params[:recipient].length > 0
      @recipients = @user.friends.message_recipients(params[:recipient])
    end

    respond_to do |format|
      format.js
    end
  end

  def create  #TODO verificar se está enviando uma mensagem para um amigo mesmo ou se ta tentando colocar o id de outra pessoa?
    authorize! :manage, @user
    messages = []

    params_recipient = params[:message].delete(:recipient)

    if params[:message][:reply_to] # resposta
      @message = Message.new(params[:message])
      @message.save!
      flash[:notice] = "Mensagem enviada!"
      respond_to do |format|
        format.js do
          return
        end
      end
    end

    if not params_recipient or  params_recipient.empty?
      @message = Message.new(params[:message])
      @message.valid?
      respond_to do |format|
        format.js do
          return
        end
      end
    end


    # If 'to' field isn't empty then make sure each recipient is valid
    params_recipient.each do |to|
      @message = Message.new(params[:message])
      @message.recipient_id = to# User.find(to)
      @message.sender = @user
      unless @message.valid?
        @recipients = @user.friends.message_recipients(params_recipient)
        respond_to do |format|
          format.js do
            return
          end
        end
        return
      else
        messages << @message
      end
    end

    # If all messages are valid then send messages
    messages.each {|msg| msg.save!}
    flash[:notice] = t :message_sent
    respond_to do |format|
      format.js do
        return
      end
    end
  end

  def delete_selected
    authorize! :manage, @user

    @message = Message.where(:id => params[:delete])
    @message.each {|m| m.mark_deleted(@user) }
    flash[:notice] = t :messages_deleted

    if params[:mailbox] == 'inbox'
      redirect_to user_messages_path(@user)
    elsif params[:mailbox] == 'outbox'
      redirect_to index_sent_user_messages_path(@user)
    end
  end
end
