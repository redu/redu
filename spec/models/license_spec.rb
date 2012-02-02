require 'spec_helper'

describe License do
  it { should belong_to :invoice }
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :period_start }
  it { should validate_presence_of :role }

  it { should allow_value('a@b.com').for(:email) }
end
