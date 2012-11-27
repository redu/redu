module VisSpecHelper
  def vis_a_request(params = "")
    a_request(:post, Redu::Application.config.vis_client[:url]).
      with(:body => params,
           :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                        'Content-Type'=>'application/json'})
  end

  def vis_stub_request
    stub_request(:post, Redu::Application.config.vis_client[:url]).
      with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                        'Content-Type'=>'application/json'}).
                        to_return(:status => 200, :body => "",
                                  :headers => {})

  end
end
