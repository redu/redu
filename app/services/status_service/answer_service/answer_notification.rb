module StatusService
  module AnswerService
    class AnswerNotification
      attr_reader :answer, :user

      def initialize(options={})
        @user = options.delete(:user)
        @answer = options.delete(:answer)
      end

      def author_name
        author.display_name
      end

      def author_avatar(size)
        author.avatar(size)
      end

      def original_author
        answer.in_response_to.user
      end

      def answer_text
        answer.text
      end

      def in_response_to
        answer.in_response_to
      end

      def author
        answer.user
      end

      def hierarchy_breadcrumbs
        BreadcrumbPresenter.new(in_response_to).to_s
      end
    end

    class BreadcrumbPresenter < Struct.new(:status)
      def to_s
        case statusable_class
        when 'Lecture' then "#{statusable.subject.name} > #{statusable.name}"
        when 'Space' then "#{statusable.course.name} > #{statusable.name}"
        when 'User' then "#{statusable.display_name}"
        else ''
        end
      end

      private

      def statusable_class
        statusable.class.to_s
      end

      def statusable
        @statusable ||= status.statusable
      end
    end
  end
end
