# -*- encoding : utf-8 -*-
module UserAgentSpecHelper
  def mock_user_agent(opts = { :mobile => false })
    user_agent = double(UserAgent)
    user_agent.stub(:mobile?) { opts[:mobile] }
    UserAgent.stub(:parse) { user_agent }
  end
end
