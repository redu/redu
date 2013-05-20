# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Api::Canvas do
  it { should belong_to :user }
  it { should belong_to :client_application }
  it { should have_one :lecture }

  context "validations" do
    subject do
      Api::Canvas.
        create(:client_application => Factory.create(:client_application))
    end
    it { should validate_presence_of :client_application }
    it { should_not allow_value("not a URL").for(:url).with_message /não é uma URL/ }
    it { should allow_value("http://google.com").for(:url) }
    it { should allow_value(nil).for(:url) }
  end

  context "#current_url" do
    subject do
      Api::Canvas.
        create(:client_application => Factory.create(:client_application))
    end
    it "should fallback to client_application URL unless #curent_url" do
      subject.current_url.should == subject.client_application.url
    end

    it "should should return #current_url if it exists" do
      subject.url = "http://foo.bar.com"
      subject.save
      subject.current_url.should == "http://foo.bar.com"
    end

    it "should return nil if there is no client application" do
      subject.stub(:client_application).and_return(nil)
      expect {
        subject.current_url
      }.to_not raise_error(NoMethodError)
    end

    it "should append the hash passed as a querystring" do
      subject.url = "http://foo.bar.com?bla=bla"
      subject.save

      qs = { :foo => :bar }
      subject.current_url(qs).should == "#{subject.url}&foo=bar"
    end

    it "should add the hash passed as a querystring" do
      subject.url = "http://foo.bar.com"
      subject.save

      qs = { :foo => :bar }
      subject.current_url(qs).should == "#{subject.url}?foo=bar"
    end
  end

  context "#current_name" do
    it "should return client application name if there is no self.name" do
      subject = Factory(:canvas, :name => nil)
      subject.current_name.should == subject.client_application.name
    end

    it "should return #name by default" do
      subject = Factory(:canvas, :name => "Guila's canvas")
      subject.current_name.should == subject.name

    end
  end
end
