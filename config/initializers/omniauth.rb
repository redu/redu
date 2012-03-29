Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '191555477625856', '27e285f90a3ee1db7a3b61641ae14694'
end
