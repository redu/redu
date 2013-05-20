# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersHelper do

  it "should generate right url" do
    url1 = "www.example.com.br"
    url2 = "http://www.example.com.br"
    url3 = "www.http://.com.br"

    [url1, url2].each do |url|
      generate_url(url).should == "http://www.example.com.br"
    end
    generate_url(url3).should == "http://www.http://.com.br"
  end

end
