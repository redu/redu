class HierarchyNotificationJob
  attr_accessor :params_array

  def initialize(opts)
    @params_array = opts[:params_array]
  end

  def perform
    EM.run {
      multi = EventMachine::MultiRequest.new
      url = Redu::Application.config.vis_client[:url]
      params_array.each  do |params|
        multi.add EM::HttpRequest.new(url).post({
        :body => params.to_json,
        :head => {'Authorization' => ["core-team", "JOjLeRjcK"],
                  'Content-Type' => 'application/json' }})
      end

      multi.callback do
        EM.stop
      end
    }
  end
end
