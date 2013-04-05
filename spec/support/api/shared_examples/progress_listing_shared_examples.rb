shared_examples_for "asset reports listing" do
  let!(:entity_name) { context.class.to_s.tableize }

  context "without filter" do
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

  context "with user_id filter" do
    let(:query_string) do
      filter_params.collect { |id| "user_id[]=#{id}&" }
    end

    before do
      get "/api/#{entity_name}/#{context.id}/progress?#{query_string}", params
    end

    it "should return only the asset reports related to those users" do
      assets = parse(response.body)
      assets_filtered = asset_reports.select do |a|
        filter_params.include? a.enrollment.user_id
      end

      assets.collect { |a| a["id"] }.to_set.should ==
        assets_filtered.collect(&:id).to_set
    end
  end
end
