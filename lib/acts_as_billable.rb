module ActsAsBillable
  extend ActiveSupport::Concern
  included do
    has_many :plans, :as => :billable
    has_one :quota, :dependent => :destroy, :as => :billable
  end

  module InstanceMethods
    # Retorna o plan atual
    def plan
      # TODO rever este código
      self.plans.order("created_at DESC").limit(1).first
    end

    # Retorna o percentual de espaço ocupado por files
    def percentage_quota_file
      if self.quota.files >= self.plan.file_storage_limit
        100
      else
        (self.quota.files * 100.0) / self.plan.file_storage_limit
      end
    end

    # Retorna o percentual de espaço ocupado por arquivos multimedia
    def percentage_quota_multimedia
      if self.quota.multimedia >= self.plan.video_storage_limit
        100
      else
        ( self.quota.multimedia * 100.0 ) / self.plan.video_storage_limit
      end
    end

    # Retorna o percentual de membros do billable
    def percentage_quota_members
      if self.users.count >= self.plan.members_limit
        100
      else
        ( self.users.count * 100.0 )/ self.plan.members_limit
      end
    end
  end
end
