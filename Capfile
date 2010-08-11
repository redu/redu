load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

# Redu specific recipes
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }