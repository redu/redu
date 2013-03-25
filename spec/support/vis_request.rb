module VisSpecHelper
  def vis_a_request(params = "")
    a_request(:post, Redu::Application.config.vis_client[:url]).
      with(:body => params,
           :headers => {'Authorization'=> auth,
                        'Content-Type'=>'application/json'})
  end

  def vis_stub_request(params = "")
    stub_request(:post, Redu::Application.config.vis_client[:url]).
      with(:headers => {'Authorization'=> auth,
                        'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => "",
                :headers => {})

  end

  private
  def auth
    Base64::encode64("core-team:JOjLeRjcK").chomp
  end
end
