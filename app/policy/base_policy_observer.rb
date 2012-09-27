class BasePolicyObserver < ActiveRecord::Observer

  def sync_policy_for(model, &block)
    producer = Permit::Producer.new(:service_name => "core")
    policy = Permit::Policy.
      new(:resource_id => permit_id(model), :producer => producer)
    policy.add(&block)
    policy.commit
  end

  def async_policy_for(model, &block)
    job = Permit::PolicyJob.new(:resource_id => permit_id(model),
                                :service_name => "core") do |policy|
      block.call(policy)
    end
    Delayed::Job.enqueue(job)
  end

  protected

  def permit_id(model)
    raise "Model not persisted. The model should have a unique ID to have it's" + \
          " Policy defined." if model.new_record?

    name = model.class.to_s.underscore
    "core:#{name}_#{model.id}"
  end
end
