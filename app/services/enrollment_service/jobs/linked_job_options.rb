# -*- encoding : utf-8 -*-
module EnrollmentService
  module Jobs
    class LinkedJobOptions
      # Armazena opções para Delayed::Job prezando por não serializar instâncias
      # do ActiveRecord.
      def initialize
        @options = {}
      end

      # Define opção para uma colleção de modelos ou instância de
      # ActiveRecord::Relation
      def set(singular_model_name, models=[])
        key = "#{singular_model_name}_ids".to_sym
        @options[key] = pluck_ids_of(models)
      end

      # Pega IDs de opção previamente definida
      def ids(singular_model_name)
        key = "#{singular_model_name}_ids".to_sym
        @options.fetch(key, [])
      end

      # Pega instância de ActiveRecord::Relation de opção previamente definida.
      def arel_of(singular_model_name)
        klass = constantize(singular_model_name)
        ids = ids(singular_model_name)

        klass.where(id: ids)
      end

      private

      def constantize(singular_model_name)
        singular_model_name.to_s.classify.constantize
      end

      def pluck_ids_of(models)
        if models.is_a?(ActiveRecord::Relation)
          models.value_of(:id)
        elsif models.respond_to?(:map)
          models.map(&:id)
        end
      end
    end
  end
end
