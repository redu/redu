require 'db/create_roles'
require 'db/create_privacies'

namespace :bootstrap do

  desc "Insert default Privacies"
  task :privacies => :environment do
    create_privacies
  end

  desc "Insert default Roles"
  task :roles => :environment do
    create_roles
    #set all existing users to 'member'
    User.update_all("role = #{Role[:member]}")
  end

  desc "Insert test administrator"
  task :default_admin => :environment do
    User.reset_callbacks(:save)
    User.reset_callbacks(:create)
    theadmin = User.new(:login => 'administrator',
                        :email => 'redu@redu.com.br',
                        :password => 'reduadmin123',
                        :password_confirmation => 'reduadmin123',
                        :birthday => 20.years.ago,
                        :first_name => 'Admin',
                        :last_name => 'Redu',
                        :activated_at => Time.now,
                        :last_login_at => Time.now,
                        :role => Role[:admin])
    theadmin.role = Role[:admin] # O default é member
    theadmin.save
    theadmin.create_settings!
  end

  desc "Insert test user"
  task :default_user => :environment do
    User.reset_callbacks(:save)
    User.reset_callbacks(:create)
    theuser = User.new(:login => 'test_user',
                       :email => 'test_user@example.com',
                       :password => 'redutest123',
                       :password_confirmation => 'redutest123',
                       :birthday => 20.years.ago,
                       :first_name => 'Test',
                       :activated_at => Time.now,
                       :last_login_at => Time.now,
                       :last_name => 'User',
                       :role => Role[:member])
    theuser.save
    theuser.create_settings!
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

  desc "Inser standard partner"
  task :partner => :environment do
    Partner.create(:name => "CNS", :email => "cns@redu.com.br")
  end

  desc "Run all bootstrapping tasks"
  task :all => [:roles, :privacies, :audiences,
                :simple_categories, :default_user, :default_admin,
                :partner]
end
