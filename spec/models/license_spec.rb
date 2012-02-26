require 'spec_helper'

describe License do
  it { should belong_to :invoice }
  it { should belong_to :course }

  [:name, :email, :period_start,
   :role, :course, :invoice].each do |validate|
    it { should validate_presence_of validate}
  end

  it { should allow_value('a@b.com').for(:email) }

  context "retrievers" do
    before do
      @user = Factory(:user)
      @environment = Factory(:environment, :owner => @user)
      @course = Factory(:course, :environment => @environment,
                       :owner => @user)
      @another_course = Factory(:course, :environment => @environment,
                        :owner => @user)
      @plan = Factory(:active_licensed_plan, :price => 3.00,
                       :billable => @environment)
      from = Date.new(2010, 01, 10)
      @plan.create_invoice({:invoice => {
        :period_start => from,
        :period_end => from.end_of_month,
        :created_at => Time.now - 1.hour }
      })
      @invoice = @plan.invoices.last
    end

    it "retrieves in use licenses" do
      @in_use = (1..10).collect { Factory(:license, :period_end => nil,
                                          :course => @course,
                                          :invoice => @invoice) }
      (1..10).collect { Factory(:license, :period_end => Date.yesterday,
                                :course => @course,
                                :invoice => @invoice) }

      License.in_use.to_set.should == @in_use.to_set
    end

    it "retrieves all licenses of a course" do
      (1..10).collect { Factory(:license, :period_end => Date.yesterday,
                                :course => @course,
                                :invoice => @invoice) }
      @licenses = (1..10).collect do
        Factory(:license, :period_end => Date.yesterday,
                :course => @another_course, :invoice => @invoice)
      end

      License.of_course(@another_course).to_set.should == @licenses.to_set
    end

    it "retrieves all payable licenses" do
      (1..3).collect { Factory(:license, :period_end => Date.yesterday,
                                :invoice => @invoice,
                                :role => Role[:environment_admin]) }
      (1..3).collect { Factory(:license, :period_end => Date.yesterday,
                                :invoice => @invoice,
                                :role => Role[:tutor]) }
      (1..3).collect { Factory(:license, :period_end => Date.yesterday,
                                :invoice => @invoice,
                                :role => Role[:teacher]) }

      @licenses = (1..10).collect do
        Factory(:license, :period_end => Date.yesterday,
                 :invoice => @invoice, :role => Role[:member])
      end

      License.payable.to_set.should == @licenses.to_set
    end
  end
end
