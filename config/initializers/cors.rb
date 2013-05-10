Rails.application.config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', :headers => :any, :methods => [:get, :post, :put, :delete]
  end

  # Permite que a busca instantânea funcione nos sub-domínios do Redu.
  allow do
    origins '*.redu.com.br'
    resource '/busca*', :headers => :any, :methods => :get
  end
end
