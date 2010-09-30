# A folder is a place where files can be stored.
# Folders can also have sub-folders.
# Via groups it is determined which actions the logged-in User can perform.
class Folder < ActiveRecord::Base
  #acts_as_ferret :store_class_name => true, :fields => { :name => { :store => :no } }
  acts_as_tree :order => 'name'

  belongs_to :user
  has_many :myfiles, :dependent => :destroy
  has_many :group_permissions, :dependent => :destroy

  belongs_to :school

  validates_uniqueness_of :name, :scope => 'parent_id', :if => Proc.new { |folder| folder.parent_id }
  validates_presence_of :name

  attr_accessible :name, :school_id, :parent_id

  # List subfolders
  # for the given user in the given order.
  def list_subfolders(logged_in_user, order)
    folders = []
    if self.can_be_read_by(logged_in_user)
    #if logged_in_user.can_read(self.id)
      self.children.find(:all, :order => order).each do |sub_folder|
        folders << sub_folder if sub_folder.can_be_read_by(logged_in_user)#logged_in_user.can_read(sub_folder.id)
      end
    end

    # return the folders:
    return folders
  end

  # List the files
  # for the given user in the given order.
  def list_files(logged_in_user, order)
    files = []
#    if logged_in_user.can_read(self.id)
    if self.can_be_read_by(logged_in_user)
      files = self.myfiles.find(:all, :order => order)
    end

    # return the files:
    return files
  end

#  # Returns whether or not the root folder exists
#  def self.root_folder_exists?
#    folder = Folder.find_by_is_root(true)
#    return (not folder.blank?)
#  end

#  # Create the Root folder
#  def self.create_root_folder
#    if User.admin_exists? #and  Folder.root_folder_exists?
#      folder = self.new
#      folder.name = 'Root folder'
#      folder.date_modified = Time.now
#      folder.is_root = true
#
#      # This folder is created by the admin
#      if user = User.find_by_is_the_administrator(true)
#        folder.user = user
#      end
#
#      folder.save # this hopefully returns true
#    end
#  end

#
#
#  PERMISSIONS
#
#

  # Use this method to determine if a user is permitted to create in the given folder
  def can_be_created_by(user, school)
    user.can_manage? school

#    self.groups.each do |group|
#      group_permission = group.group_permissions.find_by_folder_id(folder_id)
#      return true unless group_permission.blank? or not group_permission.can_create
#    end
#    return false
  end

  # Use this method to determine if a user is permitted to read in the given folder
  def can_be_read_by(user)
    true
#    self.groups.each do |group|
#      group_permission = group.group_permissions.find_by_folder_id(folder_id)
#      return true unless group_permission.blank? or not group_permission.can_read
#    end
#    return false
  end

  # Use this method to determine if a user is permitted to update in the given folder
  def can_be_updated_by(user, school)
    user.can_manage? school
#    self.groups.each do |group|
#      group_permission = group.group_permissions.find_by_folder_id(folder_id)
#      return true unless group_permission.blank? or not group_permission.can_update
#    end
#    return false
  end

  # Use this method to determine if a user is permitted to delete in the given folder
  def can_be_deleted_by(user, school)
    user.can_manage? school
#    self.groups.each do |group|
#      group_permission = group.group_permissions.find_by_folder_id(folder_id)
#      return true unless group_permission.blank? or not group_permission.can_delete
#    end
#    return false
end

def is_root
  (self.parent_id == nil)
end


end