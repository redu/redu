Factory.define(:partner) do |i|
  i.sequence(:name) { |n| "Partner No #{n}" }
end
