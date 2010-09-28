namespace :uploadify_rails do
  desc "Installs in the images, flash, and javascript for uploadify"
  task :install do
    load "#{File.dirname(__FILE__)}/../install.rb"
  end
end