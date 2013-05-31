# -*- encoding : utf-8 -*-
class VisAdapter
  attr_reader :vis_client, :url

  def initialize(opts={})
    @vis_client = opts[:vis_client] || VisClient
    @url = opts[:url] || "/hierarchy_notifications.json"
  end
end
