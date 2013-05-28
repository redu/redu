# -*- encoding : utf-8 -*-
module StatusService
  class StatusEntityService
    attr_reader :statusable

    def initialize(opts={})
      @statusable = opts.delete(:statusable)
    end

    def destroy
      Status.where(:id => statuses_ids).delete_all
    end

    private

    def statuses_ids
      statusable.statuses.values_of(:id)
    end
  end
end
