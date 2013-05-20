# -*- encoding : utf-8 -*-
class AddSomeHierarchyIndexes < ActiveRecord::Migration
  def self.up
    add_index :courses, :user_id
    add_index :courses, :environment_id
    add_index :user_environment_associations, [:user_id, :environment_id],
      :name => 'uea_user_id_environment_id'
    add_index :user_environment_associations, [:environment_id, :user_id],
      :name => 'uea_environment_id_user_id'
    add_index :user_environment_associations, :environment_id,
      :name => 'uea_environment_id'
    add_index :user_environment_associations, :user_id
    add_index :user_space_associations, [:user_id, :space_id],
      :name => 'usa_user_id_space_id'
    add_index :user_space_associations, [:space_id, :user_id],
      :name => 'usa_space_id_user_id'
    add_index :user_space_associations, :space_id
    add_index :user_space_associations, :user_id
    add_index :status_resources, :status_id
    add_index :course_enrollments, [:user_id, :course_id]
    add_index :course_enrollments, [:course_id, :user_id]
    add_index :course_enrollments, :user_id
    add_index :status_user_associations, :status_id,
      :name => 'sua_status_id'
    add_index :subjects, :space_id
    add_index :subjects, :user_id
    add_index :environments, :user_id
    add_index :lectures, :user_id
    add_index :lectures, [:lectureable_id, :lectureable_type],
      :name => 'lectures_lectureable_id_and_type'
    add_index :lectures, :subject_id
    add_index :chat_messages, :contact_id
    add_index :chat_messages, :user_id
    add_index :spaces, :user_id
    add_index :spaces, :course_id
    add_index :users, :role
  end

  def self.down
    remove_index :courses, :user_id
    remove_index :courses, :environment_id
    remove_index :user_environment_associations, :name => 'uea_user_id_environment_id'
    remove_index :user_environment_associations, :name => 'uea_environment_id_user_id'
    remove_index :user_environment_associations, :name => 'uea_environment_id'
    remove_index :user_environment_associations, :user_id
    remove_index :user_space_associations, :name => 'usa_user_id_space_id'
    remove_index :user_space_associations, :name => 'usa_space_id_user_id'
    remove_index :user_space_associations, :space_id
    remove_index :user_space_associations, :user_id
    remove_index :status_resources, :status_id
    remove_index :course_enrollments, [:user_id, :course_id]
    remove_index :course_enrollments, [:course_id, :user_id]
    remove_index :course_enrollments, :user_id
    remove_index :status_user_associations, :name => 'sua_status_id'
    remove_index :subjects, :space_id
    remove_index :subjects, :user_id
    remove_index :environments, :user_id
    remove_index :lectures, :user_id
    remove_index :lectures, :name => 'lectures_lectureable_id_and_type'
    remove_index :lectures, :subject_id
    remove_index :chat_messages, :contact_id
    remove_index :chat_messages, :user_id
    remove_index :spaces, :user_id
    remove_index :spaces, :course_id
    remove_index :users, :role
  end
end
