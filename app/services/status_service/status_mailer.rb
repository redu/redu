module StatusService
  class StatusMailer < BaseMailer
    layout 'user_notifier'

    def new_answer(notification)
      @presenter = AnswerService::AnswerPresenter.new(notification: notification)
      # Necessário por causa do layout
      @user = notification.user

      mail(to: notification.user.email, subject: "") do |format|
        format.html
      end
    end
  end
end
