# -*- encoding : utf-8 -*-
# Ativando observer do ActionMailer para criar arquivo para cada e-mail
# enviado. Os arquivos são adicionados a pasta tmp.
if Rails.env.development?
  ActionMailer::Base.register_observer(UserNotifierObserver)
end

