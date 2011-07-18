require 'spec_helper'

describe Partner do
  subject { Factory(:partner) }

  it { should respond_to :name }
  it { should validate_presence_of :name }
  it { should have_many(:environments).through(:partner_environment_associations) }
  it { should have_many(:users).through(:partner_user_associations) }

  context "when adding new collaborators" do
    before do
      3.times do
        course = Factory(:course)
        Factory(:partner_environment_association, :partner => subject,
                :environment => course.environment)
      end

      @collaborator = Factory(:user)
      subject.add_collaborator(@collaborator)
    end

    it "creates the correct association to all environments" do
      subject.environments.each do |e|
        e.administrators.should include(@collaborator)
      end
    end

    it "creates the correct association to all courses" do
      courses = subject.environments.collect { |e| e.courses }.flatten

      courses.each do |c|
        c.administrators.should include(@collaborator)
      end
    end

    it "creates the association to partner" do
      subject.users.should include(@collaborator)
    end
  end
end
