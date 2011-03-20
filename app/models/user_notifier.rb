class UserNotifier < ActionMailer::Base

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')

  self.delivery_method = :activerecord # É necessário iniciar o ar_sendmail para que os e-mails sejam enviados

  ### SENT BY MEMBERS OF SCHOOL
  def pending_membership(user,space)
    setup_sender_info
    @recipients  = "#{space.owner.email}"
    @subject     = "Disciplinas Redu: Participação pendente"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = admin_requests_space_url(space)
    @body[:space]  = space
  end

  ### SENT BY ADMIN SCHOOL
  def approve_membership(user, course)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua participacão no course \"#{course.name}\" foi aprovada!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = course.permalink
    @body[:course]  = course
  end

  def reject_membership(user, course)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua participacão no course \"#{course.name}\" foi negada!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:course]  = course
  end

  def remove_membership(user, space)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua participacão na discipĺina \"#{space.name}\" foi cancelada"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = space.permalink
    @body[:space]  = space
  end

  ### ADMIN REDU
  def remove_lecture(lecture)
    setup_sender_info
    @recipients  = "#{lecture.owner.email}"
    @subject     = "A aula \"#{lecture.name}\" foi removida do Redu"
    @sent_on     = Time.now
    @body[:user] = lecture.owner
    # @body[:url]  = lecture.permalink
    @body[:lecture]  = lecture
  end

  def remove_exam(exam)
    setup_sender_info
    @recipients  = "#{exam.owner.email}"
    @subject     = "O exame \"#{exam.name}\" foi removido do Redu"
    @sent_on     = Time.now
    @body[:user] = exam.owner
    # @body[:url]  = lecture.permalink
    @body[:exam]  = exam
  end

  def remove_user(user)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "O usuário \"#{user.login}\" foi removido do Redu"
    @sent_on     = Time.now
    @body[:user] = user
  end

  def remove_space(space)
    setup_sender_info
    @recipients  = "#{space.owner.email}"
    @subject     = "A rede \"#{space.name}\" foi removida do Redu"
    @sent_on     = Time.now
    @body[:user] = space.owner
    @body[:space]  = space
  end

  def approve_lecture(lecture)
    setup_sender_info
    @recipients  = "#{lecture.owner.email}"
    @subject     = "A aula \"#{lecture.name}\" foi aprovada!"
    @sent_on     = Time.now
    @body[:user] = lecture.owner
    @body[:url]  = lecture.permalink
    @body[:lecture]  = lecture
  end

  def reject_lecture(lecture, comments)
    setup_sender_info
    @recipients  = "#{lecture.owner.email}"
    @subject     = "A aula \"#{lecture.name}\" foi rejeitada para publicação no Redu"
    @sent_on     = Time.now
    @body[:user] = lecture.owner
    @body[:url]  = lecture.permalink
    @body[:lecture]  = lecture
    @body[:comments]  = comments
  end

  def signup_invitation(email, user, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{user.login} quer que você participe do #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = signup_by_id_url(user, user.invite_code)
    @body[:message] = message
  end

  def beta_invitation(email, beta_key)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "Você recebeu um convite para acessar a versão beta do Redu"
    @sent_on     = Time.now
    @body[:bkey] = beta_key
    @body[:url]  = APP_URL
  end

  def event_notification(user, event)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Lembre-se do evento da #{event.eventable.name}"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:event] = event
    @body[:event_url]  = polymorphic_url([event.eventable, event])
    @body[:eventable] = event.eventable
  end

  def contact_redu(contact)
    setup_sender_info
    @recipients = "#{AppConfig.contact_emails}"
    @subject    = "[#{contact.kind}] #{contact.subject}"
    @body       = "#{contact.body} \n From #{contact.name} <#{contact.email}>"
  end

  def friendship_request(friendship)
    setup_email(friendship.friend)
    @subject     += "#{friendship.user.login} would like to be friends with you!"
    @body[:url]  = pending_user_friendships_url(friendship.friend)
    @body[:requester] = friendship.user
  end

  def friendship_accepted(friendship)
    setup_email(friendship.user)
    @subject     += "Friendship request accepted!"
    @body[:requester] = friendship.user
    @body[:friend]    = friendship.friend
    @body[:url]       = user_url(friendship.friend)
  end

  def followship_notice(user, follower)
    setup_email(user)
    @subject     += "#{follower.login} está seguindo você no Redu"
    @body[:follower] = follower
  end

  def comment_notice(comment)
    setup_email(comment.recipient)
    @subject     += "#{comment.username} has something to say to you on #{AppConfig.community_name}!"
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end

  def follow_up_comment_notice(user, comment)
    setup_email(user)
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end

  def follow_up_comment_notice_anonymous(email, comment)
    @recipients  = "#{email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment

    @body[:unsubscribe_link] = url_for(:controller => 'comments', :action => 'unsubscribe', :comment_id => comment.id, :token => comment.token_for(email), :email => email)
  end

  def new_forum_post_notice(user, post)
    setup_email(user)
    @subject     += "#{post.user.login} has posted in a thread you are monitoring."
    @body[:url]  = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"
    @body[:post] = post
    @body[:author] = post.user
  end

  def signup_notification(user)
    setup_email(user)
    @subject    += "Por favor ative a sua nova conta #{AppConfig.community_name}"
    @body[:url]  = activate_url user.activation_code
  end

  def message_notification(message)
    setup_email(message.recipient)
    @subject     += "#{message.sender.login} sent you a private message!"
    @body[:message] = message
  end

  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @recipients  = "#{email}"
    @sent_on     = Time.now
    setup_sender_info
    @subject     = "Check out this story on #{AppConfig.community_name}"
    content_type "text/plain"
    @body[:name] = name
    @body[:title]  = post.title
    @body[:post] = post
    @body[:signup_link] = (current_user ?  signup_by_id_url(current_user, current_user.invite_code) : signup_url )
    @body[:message]  = message
    @body[:url]  = user_post_url(post.user, post)
    @body[:description] = truncate_words(post.post, 100, @body[:url] )
  end

  def activation(user)
    setup_email(user)
    @subject    += "Your #{AppConfig.community_name} account has been activated!"
    @body[:url]  = home_url
  end

  def reset_password(user)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua senha do #{AppConfig.community_name} foi redefinida!"
    @sent_on     = Time.now
    @body[:user] = user
  end

  def forgot_username(user)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Lembrete de login do #{AppConfig.community_name}"
    @sent_on     = Time.now
    @body[:user] = user
  end

  def environment_invitation(user, email, role, environment, message = nil)
    setup_sender_info

    @recipients  = "#{email}"
    @subject = "#{user.login} quer que você participe do #{AppConfig.community_name}!"
    @body[:user] = user
    @body[:role] = role
    @body[:message] = message
    @body[:url]  = signup_by_id_url(user, user.invite_code)
    @body[:environment] = environment.name
  end

  def payment_confirmation(user, invoice)
    setup_sender_info

    @recipients  = "#{user.email}"
    @subject = "Pagamento N. #{invoice.id} confirmado"
    @body[:user] = user
    @body[:invoice] = invoice
    @body[:plan] = invoice.plan

  end

  def overdue_notice(user, invoice)
    setup_sender_info

    @recipients  = "#{user.email}"
    @subject = "Pagamento N. #{invoice.id} pendente"
    @body[:user] = user
    @body[:invoice] = invoice
    @body[:plan] = invoice.plan

  end

  def pending_notice(user, invoice, deadline)
    setup_sender_info

    @recipients  = "#{user.email}"
    @subject = "Pagamento N. #{invoice.id} pendente"
    @body[:user] = user
    @body[:invoice] = invoice
    @body[:plan] = invoice.plan
    @body[:deadline] = deadline

  end

  def upgrade_request(user, old_plan, new_plan)
    setup_sender_info

    @recipients = "#{AppConfig.contact_emails}"
    @subject    = "[upgrade] user.id"
    @body[:user] = user
    @body[:old_plan] = old_plan
    @body[:new_plan] = new_plan
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @body[:user] = user
  end

  def setup_sender_info
    @from       = "\"Equipe Redu\" <#{AppConfig.support_email}>"
    headers     "Reply-to" => "#{AppConfig.support_email}"
    @content_type = "text/plain"
  end
end
