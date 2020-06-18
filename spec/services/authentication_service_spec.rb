# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AuthenticationService do
  describe '.initialize' do
    context 'with omniauth' do
      let(:omniauth) { OmniAuth.config.mock_auth[:some_provider] }
      let(:subject) { AuthenticationService.new(:omniauth => omniauth) }

      it 'should assign omniauth' do
        subject.omniauth.should == omniauth
      end

      it 'should assign name_service' do
        subject.name_service.should be_a NameService
      end

      it 'should assign false to connected_accounts' do
        subject.instance_variable_get("@connected_accounts").should be_false
      end
    end
  end

  describe '#authentication' do
    context 'with omniauth' do
      let(:omniauth) { OmniAuth.config.mock_auth[:some_provider] }
      let(:subject) { AuthenticationService.new(:omniauth => omniauth) }

      context 'when there is an authentication' do
        let!(:authentication) do
          FactoryBot.create(:authentication, :uid => omniauth[:uid],
                  :provider => omniauth[:provider])
        end
        it 'should return it' do
          subject.authentication.should == authentication
        end
      end

      context 'when there is not an authentication' do
        it 'should return nil' do
          subject.authentication.should be_nil
        end
      end
    end
  end

  describe '#authenticate?' do
    context 'with omniauth' do
      context "when it's the first authentication (register)" do
        let(:omniauth) { OmniAuth.config.mock_auth[:some_provider] }

        context 'with valid attributes' do
          let(:subject) { AuthenticationService.new(:omniauth => omniauth) }

          it 'should return true' do
            subject.authenticate?.should be_true
          end

          it 'should assign the authenticated user' do
            subject.authenticate?
            subject.authenticated_user.should be_a(User)
          end

          context 'User' do
            it 'should create a new user' do
              expect {
                subject.authenticate?
              }.to change(User, :count).by(1)
            end

            context 'attributes' do
              before do
                subject.authenticate?
              end

              it 'should set login for new user properly' do
                subject.authenticated_user.login.should_not be_nil
              end

              it 'should set e-mail for new user properly' do
                subject.authenticated_user.email.should ==
                  omniauth[:info][:email]
              end

              it 'should set first name for new user properly' do
                subject.authenticated_user.first_name.should ==
                  omniauth[:info][:first_name]
              end

              it 'should set last name for new user properly' do
                subject.authenticated_user.last_name.should ==
                  omniauth[:info][:last_name]
              end
            end
          end

          context 'Authentication' do
            let(:authentication) { Authentication.find_by_uid(omniauth[:uid]) }

            it 'should create a new authentication' do
              expect {
                subject.authenticate?
              }.to change(Authentication, :count).by(1)
            end

            it 'should create a new authentication for correct user' do
              subject.authenticate?
              authentication.user.should == subject.authenticated_user
            end

            context 'attributes' do
              before do
                subject.authenticate?
              end

              it 'should set uid for new authentication properly' do
                authentication.should_not be_nil
              end

              it 'should set provider for new authentication properly' do
                authentication.provider.should == omniauth[:provider]
              end
            end
          end
        end

        context 'with invalid attributes' do
          let(:invalid_omniauth) do
            omniauth.merge({
                :info => {
                :email => 'invalid.email',
                :first_name => 'John',
                :last_name => 'Doe'
              }
            })
          end
          let(:subject) do
            AuthenticationService.new(:omniauth => invalid_omniauth)
          end

          it 'should return false' do
            subject.authenticate?.should be_false
          end
        end
      end

      context 'when the user was already registered' do
        let(:user){ FactoryBot.create(:user) }
        let(:omniauth) do
          OmniAuth.config.mock_auth[:some_provider].merge({
            :info => {
              :email => user.email,
              :first_name => user.first_name,
              :last_name => user.last_name
            }
          })
        end
        let(:subject) { AuthenticationService.new(:omniauth => omniauth) }

        context 'with a provider' do
          let!(:authentication) do
            FactoryBot.create(:authentication, :user => user, :uid => omniauth[:uid],
                    :provider => omniauth[:provider])
          end

          it 'should return true' do
            subject.authenticate?.should be_true
          end

          it 'should assign the authenticated user' do
            subject.authenticate?
            subject.authenticated_user.should == user
          end

          it 'should maintain the user with the existent authentication' do
            subject.authenticate?
            subject.authenticated_user.authentications.should == [authentication]
          end
        end

        context 'directly from redu' do
          it 'should return true' do
            subject.authenticate?.should be_true
          end

          it 'should assign the authenticated user' do
            subject.authenticate?
            subject.authenticated_user.should == user
          end

          it 'should create an authentication for this user' do
            expect {
              subject.authenticate?
            }.to change { user.authentications.count }.by(1)
          end

          it "should update user's activated_at attribute" do
            subject.authenticate?
            user.reload.activated_at.should_not be_nil
          end

          it 'should set connect_accounts to true' do
            expect {
              subject.authenticate?
            }.to change { subject.connected_accounts? }.to(true)
          end
        end
      end
    end
  end

  context '#build_user' do
    context 'without omniauth' do
      let(:subject) { AuthenticationService.new(:omniauth => nil) }

      it 'should return nil' do
        subject.build_user.should be_nil
      end
    end
  end
end
