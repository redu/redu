# -*- encoding : utf-8 -*-
# O Untied é responsável por propagar os eventos definidos em
# app/doorkeepers/base_doorkeeper.rb para outros serviços. É possível debugar
# os eventos produzidos em produção tunnelando os eventos recebidos pelo
# RabbitMQ no walledgarden. Por exemplo:
#   ssh -N -L 5672:127.0.0.1:5672 deploy@walledgarden.redu.com.br
#
# Para mais informações visite http://github.com/redu/untied
Untied::Publisher.configure do |config|
  config.deliver_messages = !(Rails.env.test? || Rails.env.development?)
  config.logger = Rails.logger
  config.service_name = "core"
  config.doorkeeper = ::BaseDoorkeeper
end

# Verifica e reabre conexões com o MySQL caso elas tenham sido perdidas.
Delayed::Worker.lifecycle.before(:invoke_job) do
  ActiveRecord::Base.verify_active_connections!
end
