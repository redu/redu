class RefactoringStudentProfileAndEnrollment < ActiveRecord::Migration
  def self.up
    change_table(:enrollments) do |t|
      t.boolean  "graduaded",     :default => false
      t.float    "grade",         :default => 0.0
    end

    # Migrando os dados de student_profile antes de remover a tabelas
    StudentProfile.each do |sp|
      sp.enrollment.graduaded = sp.graduaded
      sp.enrollment.grade = sp.grade
    end

    # Alterando o usando o enrollment_id na table de asset_reports
    add_column :asset_reports, :enrollment_id, :integer
    AssetReport.each do |ap|
      ap.enrollment_id = ap.student_profile.enrollment_id
    end
    remove_column :asset_reports, :student_profile_id

    drop_table :student_profiles
  end

  def self.down
    remove_column :enrollments, :graduaded
    remove_column :enrollments, :grade

    remove_column :asset_reports, :enrollment_id
    add_column :asset_reports, :student_profile_id, :integer

    create_table "student_profiles", :force => true do |t|
      t.integer  "user_id"
      t.integer  "subject_id"
      t.boolean  "graduaded",     :default => false
      t.float    "grade",         :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "enrollment_id"
    end
  end
end
