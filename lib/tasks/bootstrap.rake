namespace :bootstrap do
  desc "Insert test administrator"
  task :default_admin => :environment do
    theadmin = User.new(:login => 'administrator',
      :email => 'admin@example.com',
      :password => 'reduadmin123',
      :password_confirmation => 'reduadmin123',
      :birthday => 20.years.ago,
      :first_name => 'Admin',
      :last_name => 'Redu',
      :role => Role[:admin])
    theadmin.generate_login_slug
    theadmin.send(:create_without_callbacks)
    puts "Administrador inserido: ", !theadmin.nil?
  end

  desc "Insert test user"
  task :default_user => :environment do
    theuser = User.new(:login => 'test_user',
      :email => 'test_user@example.com',
      :password => 'redutest123',
      :password_confirmation => 'redutest123',
      :birthday => 20.years.ago,
      :first_name => 'Test',
      :last_name => 'User',
      :role => Role[:member])
    theuser.generate_login_slug
    theuser.send(:create_without_callbacks)
    puts "Usuário comum inserido: ", !theuser.nil?
  end

  desc "Insert default Roles"
  task :roles => :environment do
    Role.enumeration_model_updates_permitted = true
    Role.create(:name => 'admin', :space_role => false)
    Role.create(:name => 'member', :space_role => false)

    # Environment
    Role.create(:name => 'environment_admin', :space_role => false)

    # Course
    Role.create(:name => 'course_admin', :space_role => false)

    # space roles
    Role.create(:name => 'teacher', :space_role => true)
    Role.create(:name => 'tutor', :space_role => true)
    Role.create(:name => 'student', :space_role => true)


    Role.enumeration_model_updates_permitted = false
    #set all existing users to 'member'
    User.update_all("role_id = #{Role[:member].id}")
  end

  desc "Insert default general categories"
  task :redu_categories => :environment do

    ReduCategory.delete_all

    categories = ['Aeronautics and Astronautics', 'Anthropology', 'Architecture', 'Automotive', 'Biology', 'Business and Management', 'Chemistry',
    'Civil and Environmental Engineering', 'Communication', 'Comparative Media Studies', 'Criminal Justice',
    'Culinary Arts', 'Earth Atmospheric and Planetary Sciences', 'Economics', 'Education', 'Electrical Engineering and Computer Science',
    'Elementary Math', 'Elementary Reading', 'Elementary Spelling', 'Environmental Studies', 'Foreign Languages', 'Health Sciences', 'History',
    'Hobbies', 'Homeschool', 'Hospitality', 'How-to', 'Journalism', 'Library Science', 'Linguistics', 'Literature', 'Materials Science and Engineering',
    'Mathematics', 'Mechanical Engineering', 'Media Arts', 'Miscellaneous', 'Music and Theater Arts', 'Nuclear Science and Engineering',
    'Nursing', 'Nutrition', 'Philosophy', 'Physical Education', 'Physics', 'Political Science', 'Psychology', 'Religion and Spirituality',
    'Self-help', 'Sociology', 'Systems Engineering', 'Test-Prep', 'Trades', 'Unit Studies', 'Urban Studies and Planning', "Women's and Gender Studies",
    'Writing']

    categories.each do |category|
     ReduCategory.create(:name => category)
    end
  end

  desc "Insert default categories"
  task :simple_categories => :environment do
    SimpleCategory.delete_all

    categories = ['Arts / Design / Animation', 'Beauty / Fashion', 'Business / Economics / Law', 'Cars / Bikes', 'Health / Wellness / Relationships', 'Hobbies / Gaming',
    'Home / Gardening', 'Languages', 'Music', 'Nutrition / Food / Drinks', 'Online Marketing', 'Religion / Philosophy', 'Science / Technology / Engineering',
    'Society / History / Politics', 'Sports', 'Other']

    categories.each do |category|
      SimpleCategory.create(:name => category)
    end
  end

  desc "Insert audiences"
  task :audiences => :environment do
    Audience.create(:name => "Ensino Superior")
    Audience.create(:name => "Ensino Médio")
    Audience.create(:name => "Ensino Fundamental")
    Audience.create(:name => "Pesquisa")
    Audience.create(:name => "Empresas")
    Audience.create(:name => "Concursos")
    Audience.create(:name => "Pré-Vestibular")
    Audience.create(:name => "Certificações")
    Audience.create(:name => "Diversos")
  end

  desc "Run all bootstrapping tasks"
  task :all => [:roles, :audiences, :redu_categories, :simple_categories, :default_user, :default_admin]
end
