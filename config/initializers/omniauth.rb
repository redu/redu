Rails.application.config.middleware.use OmniAuth::Builder do
  # Configuração de production environment.
  provider :facebook, '191555477625856', '27e285f90a3ee1db7a3b61641ae14694'
  # Configuração de development/test environment.
  # provider :facebook, '142857189169463', 'ea0f249a4df83b250c3364ccf097f35c'
end
