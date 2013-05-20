# -*- encoding : utf-8 -*-
class Message < ActiveRecord::Base

  after_create :notify_recipient

  attr_accessor :to
  attr_accessor :reply_to

  is_private_message

  validates_presence_of :body, :subject
  validates_presence_of :recipient
  validate :ensure_not_sending_to_self

  def self.new_reply(sender, in_reply_to = nil, params = {})
    message = new(params[:message])
    message.to ||= params[:to] if params[:to]

    if in_reply_to
      return nil if in_reply_to.recipient != sender #can only reply to messages you received
      message.reply_to = in_reply_to
      message.to = in_reply_to.sender.id
      message.subject = "Re: #{in_reply_to.subject}"
      message.body = "\n\n\n\n*Messagem de #{in_reply_to.sender.display_name} em #{in_reply_to.created_at}*\n\n #{in_reply_to.body}"
      message.sender = sender
    end

    message
  end

  def ensure_not_sending_to_self
    errors.add_to_base("Não é possível enviar mensagem para você, tente o nome de outra pessoa.") if self.recipient && self.recipient.eql?(self.sender)
  end

  def notify_recipient
    UserNotifier.delay(:queue => 'email').message_notification(self)
  end

end
