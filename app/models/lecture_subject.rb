class LectureSubject < ActiveRecord::Base
	
	# ASSOCIATIONS
  belongs_to :subject
  belongs_to :lectureable, :polymorphic => true

  def destroy #destroi a aula clone associada a esse lecture_subject
    self.lectureable.destroy unless self.lectureable.nil?
    super
  end
end
