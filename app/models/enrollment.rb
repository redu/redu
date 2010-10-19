class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  belongs_to :role

  def self.create_enrollment subject_id, current_user

    unless Subject.find(subject_id).limit.nil?

      if Subject.find(subject_id).limit > Subject.find(subject_id).enrolled_students.length &&  current_user.enrollments.detect{|e| e.subject_id == subject_id.to_i}.nil?
        current_user.enrollments.create(:subject_id => subject_id)
      else
        raise Exception.new("Inscrição Não Efetuada! Limite de Vagas Atingidas!")
      end
    else

      if  current_user.enrollments.detect{|e| e.subject_id == subject_id.to_i}.nil?
        current_user.enrollments.create(:subject_id => subject_id)
      else
        raise Exception.new("Inscrição Não Efetuada! Limite de Vagas Atingidas!")
      end

    end
  end
  
end
