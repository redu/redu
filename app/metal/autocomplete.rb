# -*- encoding : utf-8 -*-
# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Autocomplete
  def self.call(env)
    session = env["rack.session"]
    req = Rack::Request.new(env)
    @params = req.params
    if env["PATH_INFO"] =~ /^\/autocomplete/

      return  [200, {"Content-Type" => "application/json"}, [""]] unless @params["tag"] and session["user_credentials_id"]

      @users = User.find(session["user_credentials_id"]).friends.with_keyword(@params["tag"])
      @ab = @users.map{|u| {:key => "<img src=\""+u.avatar.url(:thumb_32)+"\"/> "+u.first_name, :value => u.id}}

      [200, {"Content-Type" => "application/json"}, [@ab.to_json]]
    else
      [404, {"Content-Type" => "application/json"}, [""]]
    end
  end
end
