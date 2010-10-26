namespace :generate_diagrams do
  
  # Need to be called before the others tasks
  desc "Removes the 'diagrams' dir and create another"
  task :create_diagrams_dir => :environment do
    FileUtils.remove_dir "diagrams", :force => true
    FileUtils.mkdir "diagrams"
  end
  
  desc "Generate models class diagram"
  task :generate_models_diagram => :environment do
    sh "railroad -o models.dot -e app/models/lecture.rb -i -l -M"
    FileUtils.mv "models.dot", "diagrams/models.dot"
  end
  
  desc "Generate controllers class diagram with inheritance"
  task :generate_controllers => :environment do
    sh "railroad -l -C -o  controllers.dot"
    FileUtils.mv "controllers.dot", "diagrams/controllers.dot"
  end
  
  desc "Generate controllers class diagram with inheritance"
  task :generate_controllers_inheritance => :environment do
    sh "railroad -l -i -C -o controllers-inheritance.dot"
    FileUtils.mv "controllers-inheritance.dot", "diagrams/controllers-inheritance.dot"
  end
  
  desc "Run all generate diagrams tasks"
  task :all => [:create_diagrams_dir, :generate_models_diagram, :generate_controllers, :generate_controllers_inheritance]
end

