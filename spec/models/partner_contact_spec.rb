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

  subject { PartnerContact.new(@params) }

  #FIXME arquivo de validação inválido
  xit { should validate_presence_of :environment_name }
  xit { should validate_presence_of :course_name }
  xit { should validate_presence_of :email }
  xit { should validate_format_of :email }
  xit { should validate_presence_of :category }

  context "when delivering" do
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
      }.should_not change(UserNotifier.deliveries, :size)
    end

    it "delivers correctly" do
      expect { subject.deliver }.should change {UserNotifier.deliveries.size }.by(1)
    end
  end
end
