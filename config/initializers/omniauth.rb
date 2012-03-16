Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '142857189169463', 'ea0f249a4df83b250c3364ccf097f35c'
end
