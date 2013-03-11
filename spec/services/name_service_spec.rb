require 'spec_helper'

describe NameService do
  let(:max_length) { 14 }
  let(:min_length) { 6 }
  let(:subject) { NameService.new(:min_length => min_length,
                                  :max_length => max_length) }

  describe '#valid_login' do
    context 'with nickname' do
      it 'should return the nickname with random part' do
        subject.valid_login({ :nickname => 'valid-nick' }).
          should match(/valid-nick[a-z0-9]{4}/)
      end

      it 'should return the nickname truncated if it is too big' do
        subject.valid_login({ :nickname => 'so-giant-nickname' }).
          should match(/so-giant-n[a-z0-9]{4}/)
      end

      it 'should return the nickname inflated if it is too small' do
        subject.valid_login({ :nickname => 'nick' }).
          should match(/nick[a-z0-9]{2}/)
      end

      it 'should return the nickname with at least min_length' do
        subject.valid_login({ :nickname => 'nick' }).
          should have_at_least(min_length).letters
      end

      it 'should return the nickname with at most max_length letters' do
        subject.valid_login({ :nickname => 'so-giant-nickname' }).
          should have_at_most(max_length).letters
      end
    end

    context 'with login' do
      it 'should return the login with random part' do
        subject.valid_login({ :login => 'validlogin' }).
          should match(/validlogin[a-z0-9]{4}/)
      end

      it 'should return the login truncated if it is too big' do
        subject.valid_login({ :login => 'so-giant-login' }).
          should match(/so-giant-l[a-z0-9]{4}/)
      end

      it 'should return the login inflated if it is too small' do
        subject.valid_login({ :login => 'login' }).
          should match(/login[a-z0-9]{1}/)
      end

      it 'should return the login with at least min_length' do
        subject.valid_login({ :login => 'login' }).
          should have_at_least(min_length).letters
      end

      it 'should return the login with at most max_length letters' do
        subject.valid_login({ :login => 'so-giant-login' }).
          should have_at_most(max_length).letters
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
          :last_name => 'doe giant' }).should match(/johndoe-gi[a-z0-9]{4}/)
      end

      it 'should return the concatenation inflated if it is too small' do
        subject.valid_login({ :first_name => 'j', :last_name => 'doe' }).
          should match(/jdoe[a-z0-9]{2}/)
      end

      it 'should return the concatenation with at least min_length' do
        subject.valid_login({ :first_name => 'j', :last_name => 'doe' }).
          should have_at_least(min_length).letters
      end

      it 'should return the concatenation with at most max_length letters' do
        subject.valid_login({ :first_name => 'j', :last_name => 'doe giant' }).
          should have_at_most(max_length).letters
      end
    end
  end
end
