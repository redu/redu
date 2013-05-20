# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Partner do
  subject { Factory(:partner) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :address }
  it { should have_many(:partner_environment_associations).dependent(:destroy) }
  it { should have_many(:partner_user_associations).dependent(:destroy) }
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

    context "when adding duplicated user" do
      it "doesnt change anything on partner admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.to_not change { subject.users }
      end

      it "doesnt change anything on environment admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.to_not change {
          subject.environments.collect { |e| e.administrators }
        }
      end

      it "doesnt change anything on course admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.to_not change {
          environments = subject.environments
          environments.collect { |e| e.courses }.flatten.collect { |c| c.administrators }
        }
      end
    end
  end

  context "when adding existing environments" do
    before do
      @environment = Factory(:environment)

      @users = 3.times.inject([]) do |acc,i|
        user = Factory(:user)
        subject.add_collaborator(user)
        acc << user
      end
    end

    it "assigns the current collaborators as new environment admins" do
      subject.add_environment(@environment, "12.123.123/1234-12", "Cool Street",
                              "Cool Inc.")
      subject.users.to_set.should be_subset(@environment.administrators.to_set)
    end
  end

  it { should respond_to :invoices}
  context "when dealing with invoices" do
    before do
      @invoices = 2.times.collect do
        env = Factory(:partner_environment_association,
                      :partner => subject).environment
        plan = Plan.from_preset(:instituicao_superior, "LicensedPlan")
        plan.user = env.owner
        env.plan = plan
        env.plan.create_invoice
      end
    end

    it "retrieves all environments' plans" do
      subject.invoices.should == @invoices
    end
  end

  it { should validate_presence_of :cnpj }
  it { should respond_to :formatted_cnpj }
  it "should return formated CNPJ" do
    subject.cnpj = "12123123123412"
    subject.formatted_cnpj.should == "12.123.123/1234-12"
  end

  context "when joining hierarchy" do
    before do
      @environments = 3.times.collect do
        course = Factory(:course)
        environment = course.environment
        Factory(:partner_environment_association, :partner => subject,
                :environment => course.environment)

        plan = Plan.from_preset(:instituicao_superior, "LicensedPlan")
        plan.user = environment.owner
        environment.plan = plan
        environment.plan.create_invoice
        environment
      end

      @collaborator = Factory(:user)
    end

    it "creates three UserEnvironmentAssociation" do
      expect{
        subject.join_hierarchy(@collaborator, Role[:environment_admin])
      }.to change(UserEnvironmentAssociation, :count).by(3)
    end

    it "creates three UserCourseAssociation" do
      expect{
        subject.join_hierarchy(@collaborator, Role[:environment_admin])
      }.to change(UserCourseAssociation, :count).by(3)
    end

    it "creates one license for each course" do
      expect{
        subject.join_hierarchy(@collaborator, Role[:environment_admin])
      }.to change(License, :count).by(3)
    end

    context "when trying to join again" do
      before do
        subject.join_hierarchy(@collaborator, Role[:environment_admin])
      end

      it "creates three UserEnvironmentAssociation" do
        expect{
          subject.join_hierarchy(@collaborator, Role[:environment_admin])
        }.to_not change(UserEnvironmentAssociation, :count)
      end

      it "creates three UserCourseAssociation" do
        expect{
          subject.join_hierarchy(@collaborator, Role[:environment_admin])
        }.to_not change(UserCourseAssociation, :count)
      end

      it "creates one license for each course" do
        expect{
          subject.join_hierarchy(@collaborator, Role[:environment_admin])
        }.to_not change(License, :count)
      end
    end
  end
end
