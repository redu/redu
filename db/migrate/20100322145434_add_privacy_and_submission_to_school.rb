class AddPrivacyAndSubmissionToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :public_profile, :boolean, :default => true
    add_column :schools, :submission_type, :integer, :default => 1
    
    School.update_all("public_profile = 1")
    School.update_all("submission_type = 1")
  end

  def self.down
    remove_column :schools, :public_profile
    remove_column :schools, :submission_type
  end
  
  
end
