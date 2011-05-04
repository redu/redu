class UserNotifier < ActionMailer::Base

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper

  self.delivery_method = :activerecord # É necessário iniciar o ar_sendmail para que os e-mails sejam enviados

  default :from => "\"Equipe Redu\" <#{Redu::Application.config.email}>",
      :content_type => "text/plain",
      :reply_to => "#{Redu::Application.config.email}"

  ### SENT BY MEMBERS OF SCHOOL
  def pending_membership(user,space)
    @user = user
    @url = admin_requests_space_url(space)
    @space = space

    mail(:to => space.owner.email,
         :subject => "Disciplinas Redu: Participação pendente",
         :date => Time.now)
  end

  ### SENT BY ADMIN SCHOOL
  def approve_membership(user, course)
    @user = user
    @url = course.permalink
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi aprovada!",
         :date => Time.now)
  end

  def reject_membership(user, course)
    @user = user
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi negada.",
         :date => Time.now)
  end

  def remove_membership(user, space)
    @user = user
    @url = space.permalink
    @space = space

    mail(:to => user.email,
         :subject => "Sua participacão na discipĺina \"#{space.name}\" foi cancelada",
         :date => Time.now)
  end

  ### ADMIN REDU
  def remove_lecture(lecture)
    @user = lecture.owner
    @lecture = lecture

    mail(:to => lecture.owner.email,
         :subject => "A aula \"#{lecture.name}\" foi removida do Redu",
         :date => Time.now)
  end

  def remove_exam(exam)
    @user = exam.owner
    @exam = exam

    mail(:to => exam.owner.email,
         :subject => "O exame \"#{exam.name}\" foi removido do Redu",
         :date => Time.now)
  end

  def remove_user(user)
    @user = user

    mail(:to => user.email,
         :subject => "O usuário \"#{user.login}\" foi removido do Redu",
         :date => Time.now)
  end

  def remove_space(space)
    @user = space.owner
    @space = space

    mail(:to => space.owner.email,
         :subject => "A disciplina \"#{space.name}\" foi removida do Redu",
         :date => Time.now)
  end

  def approve_lecture(lecture)
    @user = lecture.owner
    @url = lecture.permalink
    @lecture = lecture

    mail(:to => lecture.owner.email,
         :subject => "A aula \"#{lecture.name}\" foi aprovada!",
         :date => Time.now)
  end

  def reject_lecture(lecture, comments)
    @user = lecture.owner
    @url = lecture.permalink
    @lecture = lecture
    @comments = comments

    mail(:to => lecture.owner.email,
         :subject => "A aula \"#{lecture.name}\" foi rejeitada para publicação no Redu",
         :date => Time.now)
  end

  def signup_invitation(email, user, message)
    @user = user
    @url = signup_by_id_url(user, user.invite_code)
    @message = message

    mail(:to => email,
         :subject => "#{user.login} quer que você participe do #{Redu::Application.config.name}!",
         :date => Time.now)
  end

  def event_notification(user, event)
    @user = user
    @event = event
    @event_url = polymorphic_url([event.eventable, event])
    @eventable = event.eventable

    mail(:to => user.email,
         :subject => "Lembre-se do evento da #{event.eventable.name}",
         :date => Time.now)
  end

  def contact_redu(contact)
    mail(:to => Redu::Application.config.email,
         :subject => "[#{contact.kind}] #{contact.subject}",
         :date => Time.now)

    #FIXME não sei tranferir isso para rails 3
    @body       = "#{contact.body} \n From #{contact.name} <#{contact.email}>"
  end

  def friendship_request(friendship)
    @user = friendship.friend
    @requester = friendship.user

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] #{friendship.user.login} would like to be friends with you!",
        :date => Time.now)
    end

  def friendship_accepted(friendship)
    @user = friendship.friend
    @requester = friendship.user
    @url = user_url(friendship.friend)

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] Friendship request accepted!",
        :date => Time.now)
  end

  def comment_notice(comment)
    @url = commentable_url(comment)
    @comment = comment
    @commenter = comment.user
    @user = comment.recipient

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] #{comment.username} has something to say to you on #{Redu::Application.config.name}!")
  end

  def new_forum_post_notice(user, post)
    @post = post
    @author = post.user
    @url = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"

    mail(:to => user.email,
         :subject => "[#{Redu::Application.config.name}] #{post.user.login} has posted in a thread you are monitoring.")
  end

  def signup_notification(user)
    @url = activate_url.activation_code
    @user = user

    mail(:to => user.email,
         :subject => "[#{Redu::Application.config.name}] Por favor ative a sua nova conta #{Redu::Application.config.name}",
         :date => Time.now)
  end

  def message_notification(message)
    @user = message.recipient
    @message = message

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] #{message.sender.login} sent you a private message!",
         :date => Time.now)
  end

  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @name = name
    @title = post.title
    @post = post
    @signup_link = (current_user ?  signup_by_id_url(current_user, current_user.invite_code) : signup_url )
    @message = message
    @url = user_post_url(post.user, post)
    @description = truncate_words(post.post, 100, @url)

    mail(:to => mail,
         :subject => "Check out this story on #{Redu::Application.config.name}",
         :date => Time.now)

  end

  def activation(user)
    @user = user
    @url = home_url

    mail(:to => user.email,
         :subject => "Your #{Redu::Application.config.name} account has been activated!",
         :date => Time.now)
  end

  def reset_password(user)
    @user = user

    mail(:to => user.email,
         :subject => "Sua senha do #{Redu::Application.config.name} foi redefinida!",
         :date => Time.now)
  end

  def forgot_username(user)
    @user = user

    mail(:to => user.email,
         :subject => "Lembrete de login do #{Redu::Application.config.name}",
         :date => Time.now)
  end

  def environment_invitation(user, email, role, environment, message = nil)
    @user = user
    @role = role
    @message = message
    @url = signup_by_id_url(user, user.invite_code)
    @environment = environment.name

    mail(:to => email,
         :subject => "#{user.login} quer que você participe do #{Redu::Application.config.name}!",
         :date => Time.now)
  end

  def payment_confirmation(user, invoice)
    @user = user
    @invoice = invoice
    @plan = invoice.plan

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} confirmado",
         :date => Time.now)
  end

  def overdue_notice(user, invoice)
    @user = user
    @invoice = invoice
    @plan = invoice.plan

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} pendente",
         :date => Time.now)
  end

  def pending_notice(user, invoice, deadline)
    @user = user
    @invoice = invoice
    @plan = invoice.plan
    @deadline = deadline

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} pendente",
         :date => Time.now)
  end

  def upgrade_request(user, old_plan, new_plan)
    @user = user
    @old_plan = old_plan
    @new_plan = new_plan

    mail(:to => Redu::Application.config.email,
         :subject => "[upgrade] user.id",
         :date => Time.now)
  end

  def course_invitation_notification(user, course)
    @user = user
    @course = course

    mail(:to => user.email,
        :subject => "Você foi convidado para um curso no Redu",
        :date => Time.now)
  end

  def external_user_course_invitation(user_course_invitation, course)
    @course = course

    mail(:to => user_course_invitation.email,
         :subject => "Você foi convidado para um curso no Redu",
         :date => Time.now)
  end

end
