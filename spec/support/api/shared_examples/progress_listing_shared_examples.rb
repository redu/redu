# -*- encoding : utf-8 -*-
shared_examples_for "asset reports listing without filter" do
  let!(:entity_name) { context.class.to_s.tableize }

  before do
    get "/api/#{entity_name}/#{context.id}/progress", params
  end

  it "should return status 200" do
    response.code.should == "200"
  end

  it "should return a list of resources" do
    parse(response.body).should be_a Array
  end

  it "should return the correct number of asset reports" do
    parse(response.body).length.should == asset_reports.length
  end

  it "should return all context's asset_reports" do
    assets = parse(response.body)
    assets.collect { |a| a["id"] }.to_set.should ==
      asset_reports.collect(&:id).to_set
  end
end

shared_examples_for "asset reports listing with filter user_id" do
  let!(:entity_name) { context.class.to_s.tableize }

  let(:users_ids) { other_users[0..1].map(&:id) }
  let(:filtered_asset_reports) do
    asset_reports.select { |a|users_ids.include? a.enrollment.user_id }
  end
  let(:params_with_filter) { params.merge(:users_ids => users_ids) }

  before do
    get "/api/#{entity_name}/#{context.id}/progress", params_with_filter
  end

  it "should return only the asset reports related to those users" do
    assets = parse(response.body)

    assets.collect { |a| a["id"] }.to_set.should ==
      filtered_asset_reports.collect(&:id).to_set
  end
end

shared_examples_for "user asset reports listing with filter" do
  before do
    get "/api/users/#{user.id}/progress", params_with_filter
  end

  it "should return only the asset reports related to the filter" do
    assets = parse(response.body)

    assets.collect { |a| a["id"] }.to_set.should ==
      filtered_asset_reports.collect(&:id).to_set
  end
end
