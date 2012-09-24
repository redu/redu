class BasePolicyObserver < ActiveRecord::Observer
  def delay_policy_creation(model, &block)
    Permit::PolicyJob.new(:resource_id => permit_id(model),
                          :service_name => "core") do |policy|
      block.call(policy)
    end
  end

  protected

  def permit_id(model)
    raise "Model not persisted. The model should have a unique ID to have it's" + \
          " Policy defined." unless model.persisted?

    name = model.class.to_s.underscore
    "core:#{name}_#{model.id}"
  end
end
