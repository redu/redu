require 'spec_helper'

describe CSVNewsletter do
  let(:csv_path) { "#{Rails.root}/spec/fixtures/emails.csv" }
  subject do
    CSVNewsletter.
      new(:template => "newsletter/newsletter.html.erb", :csv => csv_path)
  end

  it "should respond to #deliver" do
    subject.should respond_to :deliver
  end

  context "#send" do
    it "should read the CSV File" do
      CSV.should_receive(:open).with(csv_path, 'r')
      subject.send
    end
  end

  context "#deliver" do
    it "should yield control to deliver" do
      args = ["guiocavalcanti@gmail.com", {}],["contato@redu.com.br", {}]
      expect { |block|
        subject.deliver(&block)
      }.to yield_successive_args(*args)
    end
  end
end
