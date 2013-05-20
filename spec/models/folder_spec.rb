# -*- encoding : utf-8 -*-
require "spec_helper"

describe Folder do
  subject { Factory(:folder) }

  it { should belong_to(:user) }
  it { should belong_to(:space) }
  it { should have_many(:folders).dependent(:destroy) }
  it { should have_many(:myfiles).dependent(:destroy) }

  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :space_id }
  it { should allow_mass_assignment_of :parent_id }

  it { validate_presence_of :name }
  it { validate_uniqueness_of(:name).scoped_to(:parent_id) }
end
