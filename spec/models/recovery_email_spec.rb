require 'spec_helper'

describe RecoveryEmail do
  subject { Factory.build(:recovery_email) }

  it { should validate_format_of(:email).with("person@email.com") }
  it { should validate_format_of(:email).with("person@email.com.br") }

  it "should mark email as invalid" do
    subject.should be_valid
    subject.mark_email_as_invalid!
    subject.errors[:email].should_not be_empty
  end
end
