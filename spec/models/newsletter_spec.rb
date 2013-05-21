# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Newsletter do
  let(:template) { "newsletter/newsletter.html.erb" }
  subject do
    Newsletter.new(:template => template)
  end

  context "#send" do
    it "should delegate to deliver" do
      subject.should_receive(:deliver)

      subject.send
    end

    it "should delegate do NewsletterMailer" do
      mail = mock('Mail', :deliver => nil)
      subject.stub(:deliver).and_yield("foo@bar.com", {})

      NewsletterMailer.should_receive(:newsletter).
        with("foo@bar.com", { :template =>  template }).and_return(mail)

      subject.send
    end

    it "should accept :subject" do
      mail = mock('Mail', :deliver => nil)
      subject.stub(:deliver).and_yield("foo@bar.com", {})

      NewsletterMailer.should_receive(:newsletter).
        with("foo@bar.com", { :template =>  template,
                              :subject => "Forever young!" }).and_return(mail)

      subject.send(:subject => "Forever young!")
    end
  end
end
