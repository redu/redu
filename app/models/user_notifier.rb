class UserNotifier < ActionMailer::Base

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper

  default :from => "\"Equipe Redu\" <#{Redu::Application.config.email}>",
      :content_type => "text/plain",
      :reply_to => "#{Redu::Application.config.email}"

  # Enviado ao aprovar a participação de um usuário num Course
  def approve_membership(user, course)
    @user = user
    @url = environment_course_url(course.environment, course)
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi aprovada!",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado ao recusar a participcação num Course
  def reject_membership(user, course)
    @user = user
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi negada.",
         :date => Time.now)
  end

  # E-mails de contato enviado para o staff
  def contact_redu(contact)
    @message = contact.body
    @abc = contact.body

    mail(:to => Redu::Application.config.email,
         :subject => "[#{contact.kind}] #{contact.subject}",
         :reply_to => contact.email,
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado para o destinatário da mensagem
  def message_notification(message)
    @user = message.recipient
    @message = message

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] #{message.sender.display_name} lhe enviou uma mensagem privada.",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando o Invoice é pago
  def payment_confirmation(user, invoice)
    @user = user
    @invoice = invoice
    @plan = invoice.plan

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} confirmado",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando o Invoice está atrasado
  def overdue_notice(user, invoice)
    @user = user
    @invoice = invoice
    @plan = invoice.plan

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} pendente",
         :date => Time.now) do |format|
      format.text
    end

  end

  # Enviado quando Invoice está pendente
  def pending_notice(user, invoice, deadline)
    @user = user
    @invoice = invoice
    @plan = invoice.plan
    @deadline = deadline

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} pendente",
         :date => Time.now) do |format|
      format.text
    end

  end

  # Enviado quando LicensedInvoice está pendente
  def licensed_pending_notice(user, invoice, deadline)
    @user = user
    @invoice = invoice
    @plan = invoice.plan
    @deadline = deadline

    mail(:to => user.email,
         :subject => "Pagamento N. #{invoice.id} pendente",
         :date => Time.now) do |format|
      format.text
    end

  end

  # Enviado quando o Plan foi bloqueado
  def blocked_notice(user, plan)
    @user = user
    @plan = plan
    @billable_name = plan.billable.try(:name) || plan.billable_audit.try(:[], "name")

    mail(:to => user.email,
         :subject => "Plano do(a) #{@billable_name} foi bloqueado",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando um upgrade de plano é requisitado
  def upgrade_request(user, old_plan, new_plan)
    @user = user
    @old_plan = old_plan
    @new_plan = new_plan

    mail(:to => Redu::Application.config.email,
         :subject => "[upgrade] #{@user.id}",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado ao convidar um usuário para um Course
  def course_invitation(user, course)
    @user, @course = user, course
    @environment = @course.environment

    mail(:to => user.email,
        :subject => "Você foi convidado para realizar um curso a distância",
        :date => Time.now) do |format|
      format.html
    end
  end

  # Enviado ao convidar um usuário não cadastrado para o Redu
  def external_user_course_invitation(user_course_invitation, course)
    @user_course_invitation = user_course_invitation
    @course = course

    mail(:to => user_course_invitation.email,
         :subject => "Você foi convidado para realizar um curso a distância",
         :date => Time.now) do |format|
      format.text
    end

  end

  # Enviado quando se tenta criar um Curso através dos parceiros
  def partner_environment_notice(partner_contact)
    @contact = partner_contact

    mail(:to => [Redu::Application.config.email, "cns@redu.com.br"],
         :subject => "[Redu] Criação de ambiente",
         :date => Time.zone.now) do |format|
      format.text
    end
  end

  # Enviado quando se demonstra interesse em migrar para plano de
  # empresa/instituição.
  def partner_environment_migration_notice(partner_contact)
    @contact = partner_contact

    mail(:to => [Redu::Application.config.email, "cns@redu.com.br"],
         :subject => "[Redu] Migração para plano empresa/instituição",
         :date => Time.zone.now) do |format|
      format.text
    end
  end

  def subject_added(user, subject)
    @user = user
    @subj = subject
    @environment = subject.space.course.environment
    @course = @subj.space.course

    mail(:subject => "Novo módulo #{@subj.name}", :to => @user.email) do |format|
      format.html
    end
  end

  def space_added(user, space)
    @user, @space, @course = user, space, space.course
    @environment = space.course.environment

    mail(:subject => "Nova disciplina: #{@space.name}",
         :to => @user.email) do |format|
      format.html
    end
  end

  def friendship_invitation(invitation)
    @invitation = invitation
    @email = invitation.email
    user = invitation.user
    uca = user.user_course_associations.approved
    @contacts = { :total => user.friends.count }
    @courses = { :total => user.courses.count,
                 :environment_admin => uca.with_roles([:environment_admin]).count,
                 :tutor => uca.with_roles([:tutor]).count,
                 :teacher => uca.with_roles([:teacher]).count }

    mail(:subject => 'Você foi convidado para do Redu', :to => @email) do |format|
      format.html
    end
  end

  # Enviado para o usuário requisitado numa requisição de conexão
  def friendship_requested(user, friend)
    @user, @friend = user, friend
    uca = @friend.user_course_associations.approved

    @contacts = { :total => @user.friends.count,
                  :in_common => user.friends_in_common_with(@friend).count }
    @courses = { :total => @friend.courses.count,
                 :environment_admin => uca.with_roles([:environment_admin]).count,
                 :tutor => uca.with_roles([:tutor]).count,
                 :teacher => uca.with_roles([:teacher]).count }

    mail(:subject => "#{friend.display_name} quer se conectar",
         :to => @user.email) do |format|
      format.html
     end
  end

  # Email de ativação de conta
  def user_signedup(user)
    @user = user

    mail(:to => user.email,
         :subject => "Ative sua conta") do |format|
      format.html
     end
  end

  # Lembre de username
  def user_forgot_username(user)
    @user = user
    email_subject = "Lembrete de login do #{Redu::Application.config.name}"

    mail(:to => user.email, :subject => email_subject) do |format|
      format.html
    end
  end

  # Redefinição de senha
  def user_reseted_password(user)
    @user = user

    mail(:to => user.email,
         :subject => "Redefinição de senha") do |format|
      format.html
    end
  end

  # Pedido de participação num Course
  def course_moderation_requested(course, admin, user)
    @course, @user = course, user
    @environment = @course.environment

    mail(:to => admin.email,
         :subject => "Moderação pendente em #{@course.name}") do |format|
      format.html
    end

  end

  def newsletter(image_name, user, subject=nil)
    @image_name = image_name
    @user = user

    mail(:to => user.email,
         :subject => subject || "Novidades do Redu") do |format|
      format.html { render :layout => false }
    end
  end
end
