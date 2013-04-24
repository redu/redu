shared_examples_for "user listing" do
  it "should return 200" do
    get "/api/#{entity_name}/#{subject.id}/users", :oauth_token => token,
      :format => 'json'

    response.code.should == '200'
  end

  it "should return the correct number of users" do
    get "/api/#{entity_name}/#{subject.id}/users", :oauth_token => token,
      :format => 'json'

    parse(response.body).length.should == members.length
  end

  it "should return the correct members" do
    get "/api/#{entity_name}/#{subject.id}/users", :oauth_token => token,
      :format => 'json'

    parse(response.body).collect { |m| m['id'] }.to_set.should ==
      members.collect(&:id).to_set
  end

  it "should filter by members" do
    get "/api/#{entity_name}/#{subject.id}/users", :role => 'member',
      :oauth_token => token, :format => 'json'

    parse(response.body).length.should == members.length - 1
  end

  it "should filter by administrator" do
    get "/api/#{entity_name}/#{subject.id}/users", :role => 'environment_admin',
      :oauth_token => token, :format => 'json'

    parse(response.body).length.should == 1
  end

  it "when return users for visualization should have only id and name" do
    get "/api/#{entity_name}/#{subject.id}/users", :reduce => true,
    :oauth_token => token, :format => 'json'

    %w(id name).each do |attr|
      parse(response.body).first.should have_key attr
    end
  end
end

