# Require any additional compass plugins here.
project_type = :rails
css_dir = "public/stylesheets"
sass_dir = "public/stylesheets/scss"
images_dir = "public/images"

config.after_initialize do
  Sass::Plugin.options[:never_update] = true
end
