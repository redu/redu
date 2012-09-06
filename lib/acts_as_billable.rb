module ActsAsBillable
  extend ActiveSupport::Concern
  included do
    has_many :plans, :as => :billable
    has_one :quota, :dependent => :destroy, :as => :billable
  end

  module InstanceMethods
    # Retorna o plano atual
    #
    # subject.plan
    # => #<PackagePlan:0x103f20f18>
    def plan
      self.plans.where(:current => true).first
    end

    # Seta o plano como o atual
    #
    # subject.plan = plan
    # => #<PackagePlan:0x103f20f18>
    # subject.plan
    # => #<PackagePlan:0x103f20f18>
    #
    # subject.plan = nil
    # => nil
    # subject.plan
    # => nil
    def plan=(new_plan)
      self.plan.try(:update_attribute, :current, false)
      new_plan.try(:update_attributes, :current => true, :billable => self)
      self.plan
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

    # Guarda suas informações no plano e se destrói
    def audit_billable_and_destroy
      plan.audit_billable! if self.plan
      self.async_destroy
    end
  end
end
