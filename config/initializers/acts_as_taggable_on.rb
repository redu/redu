# -*- encoding : utf-8 -*-
ActsAsTaggableOn.strict_case_match = true

# TODO Remover após migração para Rails 3.2
ActsAsTaggableOn::Tag.class_eval do
  class << self
    private

    def binary
      "BINARY "
    end
  end
end
