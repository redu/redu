# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Autocomplete
  def self.call(env)
    session = env["rack.session"]
    req = Rack::Request.new(env)
    @params = req.params
    if env["PATH_INFO"] =~ /^\/autocomplete/ 
      
      return  [200, {"Content-Type" => "application/json"}, [""]] unless @params["tag"] and session["user_credentials_id"]
      
      #pegar id do usuario atual: session["user_credentials_id"]
      
      
      @users = User.find_by_sql(["SELECT u.id, u.first_name, u.avatar_file_name, u.avatar_content_type, u.avatar_file_size, u.avatar_updated_at FROM users u, friendships f "+
                  "WHERE u.id = f.friend_id AND f.user_id = ? AND LOWER(first_name) LIKE ?", session["user_credentials_id"], "%" + @params["tag"] + "%"])
                  

      @ab = @users.map{|u| {:key => "<img src=\""+u.avatar.url(:thumb)+"\"/> "+u.first_name, :value => u.id}}
      
      [200, {"Content-Type" => "application/json"}, [@ab.to_json]]
    else
      [404, {"Content-Type" => "application/json"}, [""]]
    end
  end
end



 
  
