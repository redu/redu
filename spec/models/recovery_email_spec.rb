# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RecoveryEmail do
  subject { FactoryBot.build(:recovery_email) }

  it { should allow_value("person@email.com").for(:email) }
  it { should allow_value("person@email.com.br").for(:email) }

  it "should mark email as invalid" do
    subject.should be_valid
    subject.mark_email_as_invalid!
    subject.errors[:email].should_not be_empty
  end
end
