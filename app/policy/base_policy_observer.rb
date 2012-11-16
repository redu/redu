class BasePolicyObserver < ActiveRecord::Observer

  def sync_policy_for(model, &block)
    return unless model
    return if model.new_record?

    producer = Permit::Producer.new
    policy = Permit::Policy.
      new(:resource_id => permit_id(model), :producer => producer)
    policy.commit(&block)
  end

  def async_policy_for(model, &block)
    return unless model
    return if model.new_record?

    job = Permit::PolicyJob.new(:resource_id => permit_id(model)) do |policy|
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
