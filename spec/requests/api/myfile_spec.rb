# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "File API" do
  let(:environment) { FactoryBot.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:folder) { space.root_folder }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:params) { { oauth_token: token, format: 'json' } }

  context "when GET /api/files/:id" do
    subject { FactoryBot.create(:myfile, folder: folder,
                      user: course.owner) }

    before do
      get "api/files/#{subject.id}", params
    end

    it "should return code 200" do
      response.status.should == 200
    end

    %w(name mimetype size byte id).each do |attr|
      it "should have property #{attr}" do
        parse(response.body).should have_key attr
      end
    end

    %w(self folder space user raw).each do |link|
      it "should have the link #{link}" do
        href_to(link, parse(response.body)).should_not be_blank
      end
    end

    it "should have a valid link to folder" do
      href_to("folder", parse(response.body)).should =~ /#{folder.id}/
    end

    it "should return a file with a right name" do
      parse(response.body).fetch("name").should == subject.attachment_file_name
    end
  end

  context "when GET /api/folders/:folder_id/files" do
    let!(:files) { 3.times.map { FactoryBot.create(:myfile, folder: folder, user: course.owner) } }

    before do
      get "api/folders/#{folder.id}/files", params
    end

    it "should return code 200" do
      response.code.should == '200'
    end

    it "should return all files of a folder" do
      parse(response.body).length.should == 3
    end

    it "should contain a file with a certain name" do
      parse(response.body).first.fetch("name") == files.first.attachment_file_name
    end
  end

  context "when POST /api/folders/:id/files" do
    context "without validation errors" do
      let(:mimetype) { "application/vnd.ms-powerpoint" }
      let(:file) do
        path = "#{RSpec.configuration.fixture_path}/api/document_example.pptx"
        fixture_file_upload(path, mimetype)
      end
      before do
        post "/api/folders/#{folder.id}/files", params.
        merge({ file: { content: file } })
      end

      it "should return code 201" do
        response.code.should == "201"
      end

      it "should return the correct link" do
        href_to("raw", parse(response.body)).should =~ /document_example.pptx/
      end

      it "should return the correct mimetyipe" do
        parse(response.body)["mimetype"].should == mimetype
      end
    end

    context "with validation error" do
      before do
        post "/api/folders/#{folder.id}/files", params.
         merge({ file: { content: nil } })
      end

      it "should return code 422" do
        response.code.should == "422"
      end

      it "should contain validation error" do
        response.body.should =~ /attachment/
      end
    end
  end

  context "DELETE /api/files/:id" do
    subject { FactoryBot.create(:myfile, folder: folder, user: course.owner) }

    it "should return 204" do
      delete "/api/files/#{subject.id}", params
      response.code.should == "204"
    end
  end
end
