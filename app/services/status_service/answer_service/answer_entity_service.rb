module StatusService
  module AnswerService
    class AnswerEntityService
      attr_accessor :answer

      def create(status, attrs, &block)
        answer = status.answers.build(attrs) do |a|
          a.in_response_to = status
          a.statusable = status

          block.call(a) if block
        end

        answer.save

        answer
      end
    end
  end
end
