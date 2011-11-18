Rails.application.routes.draw do
  
  # Load plugin routes
  $LOAD_PATH.each do |path|
    path = File.dirname(path)
    file = File.join path, 'config', 'routes.rb'
    if File.exists? file
      require file[0..-4]
    end
  end

  match '/:anything', :to => "application#routing_error", :constraints => { :anything => /.*/ }

end