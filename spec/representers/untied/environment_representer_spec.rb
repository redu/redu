# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'support/api/oauth'
require 'support/api/base'

describe Untied::EnvironmentRepresenter do
  include Api::Helpers

  let(:environment) do
    Factory(:environment).extend(Untied::EnvironmentRepresenter)
  end
  let(:subject) do
    parse(environment.to_json).fetch('environment', {})
  end

  context "properties" do
    %w(name id avatar_url user_id).each do |p|
      it "should have property #{p}" do
        subject.should have_key(p)
      end
    end
  end

  context "avatar_url" do
    it "should include a fully-fladged URL" do
      config = Redu::Application.config.paperclip_user.clone
      config[:default_url] = 'http://foo.bar'
      Environment.has_attached_file(:avatar, config)

      subject.fetch('avatar_url', '').should == config[:default_url]
      Environment.has_attached_file(:avatar, Redu::Application.config.paperclip_user)
    end
  end
end
