require 'zip/zipfilesystem'

# Files in the database are represented by Myfile.
# It's called Myfile, because File is a reserved word.
# Files are in (belong to) a folder and are uploaded by (belong to) a User.
class Myfile < ActiveRecord::Base
  #acts_as_ferret :store_class_name => true, :fields => { :text => { :store => :yes }, :filename => { :store => :no } }
  has_attached_file :attachment
  
  belongs_to :folder
  belongs_to :user

  has_many :usages, :dependent => :destroy

  validates_uniqueness_of :attachment_file_name, :scope => 'folder_id'

  before_destroy :delete_file_on_disk
  # When removing a myfile record from the database,
  # the actual file on disk has to be removed too.
  # That is exactly what this method does.
  def delete_file_on_disk
   # File.delete self.path
  end

end