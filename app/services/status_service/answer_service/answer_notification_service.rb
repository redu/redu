module StatusService
  module AnswerService
    class AnswerNotificationService < Struct.new(:answer)
      def deliver
        involved_users do |user|
          notification = AnswerNotification.new(user: user, answer: answer)
          build_and_deliver(notification)
        end
      end

      private

      def build_and_deliver(notification)
        mailer.delay(queue: :email).new_answer(notification)
      end

      def original_status
        answer.in_response_to
      end

      def involved_users(&block)
        user_ids = Answer.where(in_response_to_id: original_status).value_of(:user_id)
        user_ids << original_status.user_id
        user_ids.delete(answer.user_id)

        User.where(id: user_ids.uniq).find_each(&block) if block_given?
      end

      def mailer
        StatusMailer
      end
    end
  end
end
