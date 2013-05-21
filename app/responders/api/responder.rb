# -*- encoding : utf-8 -*-
module Api
  module Responder
    include Roar::Rails::Responder

    # Retrocompatibilidade: Rails 3.2+ empacota erros em um hash do
    # tipo { :errors => ... } (http://tinyurl.com/c6wxq7c)
    def json_resource_errors
      resource.errors
    end
  end
end
