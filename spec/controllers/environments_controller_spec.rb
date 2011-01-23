require 'spec_helper'
require 'authlogic/test_case'

describe EnvironmentsController do
  context "when creating an Environment" do
    context "when POST create at step 1" do
      before do
        @user = Factory(:user)
        activate_authlogic
        UserSession.create @user
      end

      before do
        @params = {:step => 1, :locale => "pt-BR", 
          :environment => {:name => "Faculdade mauricio de nassau", 
            :courses_attributes => [{:name => "Gestão de TI", 
                                     :path => "gestao-de-ti"}], 
          :path => "faculdade-mauricio-de-nassau"}}

        post :create, @params
      end

      it "assigns the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
      end

      it "assigns the plans" do
        assigns[:plan].should_not be_nil
      end
      
    
    end
    
  
  end

end
