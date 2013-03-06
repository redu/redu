require 'spec_helper'

describe NameService do
  let(:subject) { NameService.new(:min_length => 6, :max_length => 14) }

  describe '#valid_login' do
    context 'with nickname' do
      it 'should return the nickname with random part' do
        subject.valid_login({ :nickname => 'valid-nick' }).
          should match(/valid-nick[a-z0-9]{4}/)
      end

      it 'should return the nickname truncated if it is too big' do
        subject.valid_login({ :nickname => 'so-giant-nickname' }).
          should match(/so-giant-ni[a-z0-9]{4}/)
      end

      it 'should return the nickname inflated if it is too small' do
        subject.valid_login({ :nickname => 'nick' }).
          should match(/nick[a-z0-9]{2}/)
      end
    end

    context 'with login' do
      it 'should return the login with random part' do
        subject.valid_login({ :login => 'validlogin' }).
          should match(/validlogin[a-z0-9]{4}/)
      end

      it 'should return the login truncated if it is too big' do
        subject.valid_login({ :login => 'so-giant-login' }).
          should match(/so-giant-lo[a-z0-9]{4}/)
      end

      it 'should return the login inflated if it is too small' do
        subject.valid_login({ :login => 'login' }).
          should match(/login[a-z0-9]{1}/)
      end
    end

    context 'with first_name and last_name informed' do
      it 'should return the concatenation with random part' do
        subject.valid_login({ :first_name => 'john', :last_name => 'doe' }).
          should match(/johndoe[a-z0-9]{4}/)
      end

      it 'should return the concatenation truncated if it is too big' do
        subject.valid_login({
          :first_name => 'john',
          :last_name => 'doe giant' }).should match(/johndoe-gia[a-z0-9]{4}/)
      end

      it 'should return the concatenation inflated if it is too small' do
        subject.valid_login({ :first_name => 'j', :last_name => 'doe' }).
          should match(/jdoe[a-z0-9]{2}/)
      end
    end
  end
end
