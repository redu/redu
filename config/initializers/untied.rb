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

# Inicializa novamente o EM numa thread separada apenas no contexto do DelayedJob.
# Isso é necessário pois o reactor não sobrevive a forks de processo.
Delayed::Worker.lifecycle.before(:invoke_job) do
  if !defined?(@@em_thread) && Delayed::Worker.delay_jobs
    Delayed::Worker.logger.info "Initializing EM and AMQP"
    EM.stop if EM.reactor_running?
    @@em_thread = Thread.new do
      EventMachine.run { AMQP.start }
    end
    sleep(0.25)
  end
end
