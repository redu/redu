# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Autocomplete
  def self.call(env)
    session = env["rack.session"]
    req = Rack::Request.new(env)
    @params = req.params
    if env["PATH_INFO"] =~ /^\/autocomplete/ 
      
      return  [200, {"Content-Type" => "application/json"}, [""]] unless @params["tag"]
      
      #pegar id do usuario atual: session["user_credentials_id"]
      
      @users = User.find_by_sql(["SELECT id,first_name, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at FROM users "+
                  "WHERE LOWER(first_name) LIKE ?", "%" + @params["tag"] + "%"])
                  
    # TODO aninhar SQL para pegar amigos somente

      @ab = @users.map{|u| {:key => "<img src=\""+u.avatar.url(:thumb)+"\"/> "+u.first_name, :value => u.id}}
      
      [200, {"Content-Type" => "application/json"}, [@ab.to_json]]
    else
      [404, {"Content-Type" => "application/json"}, [""]]
    end
  end
end



 
  
