class Quota < ActiveRecord::Base
  belongs_to :billable

  # Soma valor do attachment de uma entidade ao total de quotas
  def refresh
    multimedia_size = self.billable.multimedia_size
    files_size = self.billable.files_size
  end
end
