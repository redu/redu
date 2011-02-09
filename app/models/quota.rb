class Quota < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true

  # Soma valor do attachment de uma entidade ao total de quotas
  def refresh
    # recupera o tamanho dos arquivos inseridos nas disciplinas de um course
    myfiles = Myfile.find_by_sql(["SELECT IFNULL(SUM(IFNULL(m.attachment_file_size, 0)), 0) as attachment_file_size FROM spaces s LEFT JOIN folders f ON s.id = f.space_id LEFT JOIN myfiles m ON f.id = m.folder_id WHERE course_id = ?", self.billable.id])
    # recurepa os arquivos referentes ao seminar de um determinado course
    seminars = Seminar.find_by_sql(["SELECT IFNULL((SUM(IFNULL(se.original_file_size, 0)) + SUM(IFNULL(se.media_file_size, 0))), 0) AS original_file_size FROM spaces s LEFT JOIN subjects su ON su.space_id = s.id LEFT JOIN lectures l ON l.subject_id = su.id LEFT JOIN seminars se ON l.lectureable_id = se.id where l.lectureable_type = 'Seminar' AND s.course_id = ?", self.billable.id])
    # recupera os arquivos referentes ao document de um determinado course
    documents = Document.find_by_sql(["SELECT IFNULL(SUM(IFNULL(d.attachment_file_size, 0)), 0) AS attachment_file_size FROM spaces s LEFT JOIN subjects su ON su.space_id = s.id LEFT JOIN lectures l ON l.subject_id = su.id LEFT JOIN documents d ON l.lectureable_id = d.id WHERE l.lectureable_type LIKE 'Document' AND s.course_id = ?", self.billable.id])
    # recupera as imagens inseridas via page, event ou bulletin em todos spaces de um curso
    ckeditor_space_files = Ckeditor::Asset.find_by_sql(["SELECT IFNULL(SUM(ck.data_file_size), 0) AS data_file_size FROM spaces s LEFT JOIN ckeditor_assets ck ON s.id =  ck.assetable_id WHERE ck.assetable_type LIKE 'Space' AND s.course_id = ?", self.billable.id])
    # ckeditor_environment_files = Ckeditor::Asset.find_by_sql(["SELECT IFNULL(SUM(ck.data_file_size), 0) AS data_file_size FROM courses c RIGHT JOIN environments e ON c.environment_id = e.id LEFT JOIN ckeditor_assets ck ON e.id = ck.assetable_id WHERE ck.assetable_type LIKE 'Environment' AND c.id = ?", self.billable.id])

    multimedia_size = seminars[0].original_file_size
    files_size = myfiles[0].attachment_file_size + documents[0].attachment_file_size +
      ckeditor_space_files[0].data_file_size
    self.update_attributes(:multimedia => multimedia_size, :files => files_size)
  end

end
