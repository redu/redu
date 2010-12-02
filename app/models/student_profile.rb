class StudentProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :asset

  validates_uniqueness_of :user_id, :scope => :subject_id

  # Atualiza a porcentagem de cumprimento do módulo. Quando não houver mais recursos
  # a serem cursados, retorna false.
  def update_grade!
    current_index = self.asset.position
    total = self.subject.assets.count

    self.grade = ( current_index.to_f * 100 ) / total
    unless total == current_index
      next_asset = self.subject.assets.find(:first,
                      :conditions => {:position => current_index + 1})
      self.asset = next_asset
    else
      self.grade = 100
      self.graduaded = true
    end
    self.save

    return !next_asset.nil?
  end
end
