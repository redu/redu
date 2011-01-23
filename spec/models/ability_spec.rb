require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  
  before do
      @env_admin = Factory(:user)
      @member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @redu_admin = Factory(:user, :role => :admin)
  end

  context "on environment -" do
    
    before do
      @environment = Factory(:environment, :owner => @env_admin)
    end

    context "member" do
      before do
        Factory(:user_environment_association, :environment => @environment,
              :user => @member, :role => :member)
        @ability = Ability.new(@member)
      end
      it "creates a environment" do
        env = Factory.build(:environment, :owner => @member)
        @ability.should be_able_to(:create, env)
      end

      it "destroys his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment, :owner => @member))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end
    end

    context "envinronment_admin" do
      before do
        @ability = Ability.new(@env_admin)
      end
      #FIXME aparentemente um usuário pode criar um ambiente em que o owner seja outro usuário
      it "creates a environment" do
        @ability.should be_able_to(:create, Factory.build(:environment,
                                                          :owner => @env_admin))
      end
      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, @environment)
      end

      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, 
                                       Factory.build(:environment, 
                                                     :owner => @redu_admin))
      end
    end
   
    context "teacher" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @teacher, :role => :teacher)
        @ability = Ability.new(@teacher)
      end

      it "creates a environment" do
        @ability.should be_able_to(:create, 
                                   Factory.build(:environment,
                                                 :owner => @teacher))
      end
      it "destroy his own environment" do
        @ability.should be_able_to(:destroy,
                                   Factory(:environment,
                                                 :owner => @teacher))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end
    end

    context "tutor" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @tutor, :role => :teacher)
        @ability = Ability.new(@tutor)
      end
      it "creates a environment" do
        @ability.should be_able_to(:create, Factory.build(:environment,
                                                          :owner => @tutor))
      end

      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment,
                                                     :owner => @tutor))
      end
        
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end
    
    end
    
    context "redu admin" do
      before do
        @ability = Ability.new(@redu_admin)
      end
      it "creates a environment" do
        @ability.should be_able_to(:create, 
                                   Factory.build(:environment,
                                                 :owner => @redu_admin))
      end     

      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment,
                                                     :owner => @redu_admin))
      end
      it "cannot destroy a strange environment" do
        @ability.should be_able_to(:destroy, @environment)
      end
    end

  end
  context "on course -" do
    before do
      @environment = Factory(:environment, :owner => @env_admin)
      Factory(:user_environment_association, :environment => @environment,
              :user => @member, :role => :member)
    end
    context "member" do
      before do
        @ability = Ability.new(@member)  
      end

      it "cannot create a course" do
        course = Factory.build(:course,:owner => @member ,:environment => @environment)
        @ability.should_not be_able_to(:create, course)
      end
      it "cannot destroy a course" do
        course = Factory.build(:course, :owner => @env_admin,
                               :environment => @environment)
        @ability.should_not be_able_to(:destroy, course)
      end
    end

    context "environment admin" do
     it "creates a course" 
     it "destroys his course"
     it "cannot destroy a strange course"
    end
    
    context "redu admin" do
     it "creates a course" 
     it "destroys his course"
     it "cannot destroy a strange course"
    end

    context "teacher" do
     it "creates a course" 
     it "destroys his course"
     it "cannot destroy a strange course"
    end

    context "tutor" do
     it "creates a course" 
     it "destroys his course"
     it "cannot destroy a strange course"
    end
  end

  context "on space -" do
    before do      
      @environment = Factory(:environment, :owner => @env_admin)
      Factory(:user_environment_association, :environment => @environment,
              :user => @member, :role => :member)
    end
    context "member" do
      before do
        @ability = Ability.new(@member)
        @course = Factory(:course, :owner => @env_admin,
                          :environment => @environment)

      end

      it "cannot create a space" do
        @ability.should_not be_able_to(:create, Factory(:space, 
                                                        :owner => @member,
                                                        :course => @course))
      end
      it "cannot destroy a space" do
        @ability.should_not be_able_to(:destroy, Factory(:space,
                                                         :owner => @member,
                                                         :course => @course))
      end

      it "cannot create a subject"
      it "cannot destroy any subject"
      it "cannot create a lecture"
      it "cannot destroy any lecture"
      it "cannot create an event"
      it "cannot destroy any event"
      it "cannot create a bulletin"
      it "cannot destroy any bulletin"
      it "cannot upload a file"
      it "cannot destroy any file"
      it "crates a post"

    end

    context "teacher" do
      it "cannot create a space"
      it "cannot destroy a space"
      it "cannot create a subject"
      it "cannot destroy any subject"
      it "cannot create a lecture"
      it "cannot destroy any lecture"
      it "cannot create an event"
      it "cannot destroy any event"
      it "cannot create a bulletin"
      it "cannot destroy any bulletin"
      it "cannot upload a file"
      it "cannot destroy any file"
      it "crates a post"
    end

    context "tutor" do
      it "cannot create a space"
      it "cannot destroy a space"
      it "cannot create a subject"
      it "cannot destroy any subject"
      it "cannot create a lecture"
      it "cannot destroy any lecture"
      it "cannot create an event"
      it "cannot destroy any event"
      it "cannot create a bulletin"
      it "cannot destroy any bulletin"
      it "cannot upload a file"
      it "cannot destroy any file"
      it "crates a post"
    end

    context "redu admin" do
      it "creates a space"
      it "destroys a space"
      it "creates a subject"
      it "destroys any subject"
      it "creates a lecture"
      it "destroys any lecture"
      it "creates an event"
      it "destroys any event"
      it "creates a bulletin"
      it "destroys any bulletin"
      it "uploads a file"
      it "destroys any file"
      it "crates a post"
    end

  end

  context "on plan" do
    context "the member" do
      it "creates a plan" do
        anyone = Factory(:user)
        plan = Factory.build(:plan, :user => anyone)
        ability = Ability.new(anyone)

        ability.should be_able_to(:create, plan)
      end
    end

    context "the owner" do
      it "manages its own plan" do
        plan = Factory(:plan)
        ability = Ability.new(plan.user)

        ability.should be_able_to(:manage, plan)
      end
    end

    context "the strange" do
      it "cant read others plans" do
        strange = Factory(:user)
        plan = Factory(:plan)
        ability = Ability.new(strange)

        ability.should_not be_able_to(:read, plan)
      end
    end

  end
end
