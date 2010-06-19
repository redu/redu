class CreateRootFolders < ActiveRecord::Migration
  def self.up
    #adiciona diretorio raizes nas escolas já existentes
    @schools = School.all
    @schools.each do |school|
     Folder.create :name => "root", :school_id => school.id 
    end
  end

  def self.down
  end
end
