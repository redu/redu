# -*- encoding : utf-8 -*-
RSpec::Matchers.define :accept_nested_attributes_for do |association_name|
  match do |actual|
    actual.methods.include?("#{association_name}_attributes=")
  end

  failure_message_for_should do |actual|
    "expected that #{actual.class.to_s} would accept nested attributes for #{association_name}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.class.to_s} would not accept nested attributes for #{association_name}"
  end

  description do
    "accept nested attrs for #{association_name}"
  end
end

