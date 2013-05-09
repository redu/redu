require 'spec_helper'

describe PartnerContact do
  before do
    @params = {
      :environment_name => "Centro de informática",
      :course_name => "Ciência da computação",
      :email => "contato@redu.com.br",
      :category => "company"
    }
  end


  #FIXME arquivo de validação inválido
  xit { should validate_presence_of :environment_name }
  xit { should validate_presence_of :course_name }
  xit { should validate_presence_of :email }
  xit { should validate_format_of :email }
  xit { should validate_presence_of :category }

  context "when delivering" do
    subject { PartnerContact.new(@params) }

    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    it "responds to deliver" do
      subject.should respond_to(:deliver)
    end

    it "delivers only valid contacts" do
      subject.environment_name = ""

      expect {
        subject.deliver
      }.to_not change(UserNotifier.deliveries, :size)
    end

    it "delivers correctly" do
      expect { subject.deliver }.to change {UserNotifier.deliveries.size }.by(1)
    end
  end

  context "when contact is about a migration" do
   before  do
     @params = {
      :migration => true,
      :billable_url => "/upe/cursos/enfermagem",
      :email => "contato@redu.com.br",
      :category => "company"
     }
   end

   subject { PartnerContact.new(@params) }

   it "should be valid even not having environment_name and course_name" do
     subject.environment_name = ""
     subject.course_name = ""
     subject.should be_valid
   end

   it "should validates presence of billable_url" do
     subject.billable_url = ""
     subject.should_not be_valid
   end


   context "when delivering" do
     before do
       UserNotifier.delivery_method = :test
       UserNotifier.perform_deliveries = true
       UserNotifier.deliveries = []
     end

     it "delivers correctly" do
       expect { subject.deliver }.to change {UserNotifier.deliveries.size }.by(1)
     end

     it "delivers migration message" do
      subject.deliver
      UserNotifier.deliveries.last.body.should =~ /se mostrou interessado em migrar/
      UserNotifier.deliveries.last.body.should =~ /#{subject.billable_url}/
     end
   end
  end
end
