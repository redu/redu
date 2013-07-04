# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ContactsController do
    let(:params) { { locale: 'pt-BR' } }
  describe "GET 'new'" do
    it "should assign Contact" do
      get :new, params
      expect(assigns[:contact]).to be_a Contact
    end
  end

  describe "POST 'create'" do
    it "should deliver contact" do
      attrs = { name: "Guila", email: "foo@bar.com", kind: "Dúvida",
                body: "hello" }
      expect {
        post :create, params.merge(contact: attrs)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

end
