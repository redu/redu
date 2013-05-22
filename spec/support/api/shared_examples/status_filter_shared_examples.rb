# -*- encoding : utf-8 -*-
# Argumentos:
#   - url: URL para a qual será feita a requisição
#   - params: parâmetros que serão enviados via querystring
#   - token
#   - statuses
shared_examples_for "status filter" do
  let(:base_params) { { oauth_token: token, format: :json } }
  let(:types) { statuses.map(&:type).uniq }

  it "should filter by one type" do
    types.each do |type|
      get url, base_params.merge(type: type)

      response.code.should == "200"
      parse(response.body).map { |s| s["id"] }.should == expected_ids(type)
    end
  end

  it "should filter by multiple types" do
    get url, base_params.merge(types: types)
    parse(response.body).map { |s| s["id"] }.should == expected_ids(types)
  end

  it "should filter by some types" do
    get url, base_params.merge(types: types[0..1])
    parse(response.body).map { |s| s["id"] }.should == expected_ids(types[0..1])
  end

  def expected_ids(types)
    types = types.respond_to?(:map) ? types : [types]
    statuses.select { |s| types.include? s.type }.map(&:id)
  end
end

