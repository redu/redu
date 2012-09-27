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
    Partner.create(:name => "CNS",
                   :email => "cns@redu.com.br",
                   :cnpj => "12.123.123/1234-12",
                   :address => "Beaker street")
  end

  desc "Create OAuth Client Application for ReduVis"
  task :reduvis_app => :environment do
    user_admin = User.find_by_id(2)

    ClientApplication.create(:name => "ReduVis",
                             :url => "http://www.redu.com.br",
                             :user => user_admin)
  end

  desc "Run all bootstrapping tasks"
  task :all => [:roles, :privacies, :audiences,
                :default_user, :default_admin,
                :partner, :reduvis_app]
end
