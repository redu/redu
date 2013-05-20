# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LicensedPlan do
  subject { Factory(:active_licensed_plan) }

  it "should have a infinity members limit" do
    infinity = 1.0/0
    subject.members_limit.should == infinity
  end

  it { should respond_to :create_invoice }

  context "when creating invoices" do
    before do
      Date.stub(:today) { Date.new(2010, 02, 07) }

      subject.create_invoice
      @invoice = subject.invoices.last
    end

    it "should be valid" do
      @invoice.should be_valid
    end

    it "should defaults to open" do
      @invoice.should be_open
    end

    it "should initiates period today" do
      @invoice.period_start.should == Date.today
    end

    it "should ends period on 20th day of month" do
      @invoice.period_end.should == Date.new(2010, 02, 20)
    end

    context "when start period is after 20th day of month" do
      before do
        Date.stub(:today) { Date.new(2010, 02, 23) }

        subject.create_invoice
        @invoice = subject.invoices.last
      end

      it "should end period on next month 20th day" do
        @invoice.period_end.should == Date.new(2010, 03, 20)
      end
    end

    it "should initiates without amount" do
      @invoice.amount.should be_nil
    end

    context "when passing attributes" do
      before do
        @from = Date.today + 20.days
        subject.create_invoice({:invoice => {
          :period_start => @from,
          :period_end => @from.end_of_month,
          :amount => 10.00} })
        @invoice = subject.invoices.last
      end

      it "should have correct attributes" do
        @invoice.period_start.should == @from
        @invoice.period_end.should == @from.end_of_month
      end

      it "should not accept amount value" do
        @invoice.amount.should be_nil
      end
    end
  end

  it { should respond_to :create_invoice_and_setup }
  context "when setting up the plan" do
    before do
      @plan = Plan.from_preset(:instituicao_superior, "LicensedPlan")
    end

    it "should preset the correct plan" do
      @plan.name.should == LicensedPlan::PLANS[:instituicao_superior][:name]
    end

    it "should create an invoice" do
      expect {
        @plan.create_invoice_and_setup
      }.to change(Invoice, :count).by(1)
    end
  end

  context "when setting up for migration" do
    before do
      subject.invoice = Factory(:licensed_invoice)
    end

    context "when billable is a course" do
      before do
        subject.invoice = Factory(:licensed_invoice)
        subject.billable = Factory(:course)
        (1..20).each { subject.billable.join Factory(:user)}
      end

      it "should create licenses for all course users" do
        expect {
          subject.setup_for_migration
        }.to change(License, :count).
          by(subject.billable.approved_users.count)
      end

      it "should create license with correct infos" do
        subject.setup_for_migration

        user = subject.billable.approved_users.first
        uca = user.user_course_associations.first
        lic = subject.invoice.licenses.where(:login => user.login).first

        lic.should_not be_nil
        lic.course.should == uca.course
        lic.role.should == uca.role
      end
    end

    context "when billable is a environment" do
      before do
        subject.billable = Factory(:environment)
        (1..3).each { Factory(:course, :environment => subject.billable) }
        subject.billable.reload
        subject.billable.courses.each do |c|
          (1..20).each { c.join Factory(:user)}
        end
      end

      it "should create licenses for all courses users" do
        users = subject.billable.courses.collect(&:approved_users)
        expect {
          subject.setup_for_migration
        }.to change(License, :count).by(users.flatten.size)
      end

      it "should create license with correct infos" do
        subject.setup_for_migration

        user = subject.billable.courses.first.approved_users.first
        uca = user.user_course_associations.first
        lic = subject.invoice.licenses.where(:login => user.login).first

        lic.should_not be_nil
        lic.course.should == uca.course
        lic.role.should == uca.role
      end
    end
  end
end
