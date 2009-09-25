#load everything in /engine_config/initializers
# initializers in your root 'initializers' directory will take precedence if they have the same file name


if AppConfig.theme
  theme_view_path = "#{RAILS_ROOT}/themes/#{AppConfig.theme}/views"
  ActionController::Base.view_paths = ActionController::Base.view_paths.dup.unshift(theme_view_path)
end
