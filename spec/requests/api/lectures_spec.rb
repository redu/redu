require 'api_spec_helper'

describe 'Lectures' do
  before do
    @application, @current_user, @token = generate_token
  end

  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
  end
  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
  end
  let(:environment) do
    Factory(:complete_environment, :owner => @current_user)
  end
  let(:subj) do
    course = environment.courses.first
    space = course.spaces.first
    Factory(:subject, :space => space, :owner => space.owner)
  end
  let(:page) do
    Factory(:lecture, :owner => subj.owner, :subject => subj)
  end

  context "pointers" do
    it "should have the correct links" do
      2.times.collect do
        Factory(:lecture, :owner => subj.owner, :subject => subj)
      end
      page.move_up!

      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)

      %w(self next_lecture previous_lecture).each do |link|
        get href_to(link, entity), params
        response.code.should == '200'
      end
    end

    it "should navigate through the links" do
      # Criando 3 aulas
      page
      2.times.collect do
        Factory(:lecture, :owner => subj.owner, :subject => subj)
      end

      # Primeira aula
      get "/api/lectures/#{subj.lectures.first.id}", params
      first = parse(response.body)
      response.code.should == '200'

      # Segunda aula
      get href_to('next_lecture', first), params
      second = parse(response.body)
      response.code.should == '200'
      href_to('previous_lecture', second).should == href_to('self', first)

      # Última aula
      get href_to('next_lecture', second), params
      third = parse(response.body)
      response.code.should == '200'
      href_to('previous_lecture', third).should == href_to('self', second)
      third['next_lecture'].should be_nil
    end
  end

  context "when GET /api/lectures/:id" do
    it "should return HTTP code 200" do
      get "/api/lectures/#{page.id}", params
      response.code.should == '200'
    end

    it "should have the correct properties" do
      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)

      %w(id type name created_at view_count position rating lectureable position).
        each { |attr| entity.should have_key(attr) }
    end
  end

  context "when GET /api/subjects/:subect_id/lectures" do
    it "should return HTTP code 200" do
      get "/api/subjects/#{subj.id}/lectures", params
      response.code.should == '200'
    end

    it "should return HTTP code 404 when subject doesnt exist" do
      get "/api/subjects/21212/lectures", params
      response.code.should == '404'
    end

    it "should return the correct number of lectures" do
      page
      2.times.collect do
        Factory(:lecture, :owner => subj.owner, :subject => subj)
      end

      get "/api/subjects/#{subj.id}/lectures", params
      parse(response.body).length.should == 3
    end

    context "filtering" do
      before do
        # Page
        Factory(:lecture, :owner => subj.owner, :subject => subj)
        # Seminar
        Factory(:lecture, :owner => subj.owner, :subject => subj,
                :lectureable => Factory(:seminar_youtube))

        # Document
        mock_scribd_api
        doc = Factory.build(:document)
        document_path = "#{Rails.root}/spec/support/documents/document_test.pdf"
        File.open(document_path, 'r') { |f| doc.attachment = f }
        doc.save

        Factory(:lecture, :owner => subj.owner, :subject => subj,
                :lectureable => doc)

      end

      it "should filter by lectureable type (page)" do
        get "/api/subjects/#{subj.id}/lectures", params.merge!({:type => 'page'})
        entity = parse(response.body)

        entity.should_not be_empty
        entity.all? { |l| l['type'] == 'Page' }.should be_true
      end

      it "should filter by lectureable type (seminar)" do
        get "/api/subjects/#{subj.id}/lectures", params.merge!({:type => 'seminar'})
        entity = parse(response.body)

        entity.should_not be_empty
        entity.all? { |l| l['type'] == 'Seminar' }.should be_true
      end

      it "should filter by lectureable type (document)" do
        get "/api/subjects/#{subj.id}/lectures", params.merge!({:type => 'document'})
        entity = parse(response.body)

        entity.should_not be_empty
        entity.all? { |l| l['type'] == 'Document' }.should be_true
      end

      it "should filter by lectureable type (exercise)"
    end
  end

  context "POST a lecture" do
    context "when page type" do
      before do
        params.merge!( { :lecture => { :name => "New Lecture", :type => "Page",
                                     :body => "Text body lecture page type" } })
      end

      it "should return code 201 page" do
        post "/api/subjects/#{subj.id}/lectures", params
        response.code.should == "201"
      end

      it "should return code 422" do
        params[:lecture][:name] = ""
        post "/api/subjects/#{subj.id}/lectures", params
        response.code.should == "422"
      end

      it "should return code 422 (body empty)" do
        params[:lecture][:body] = ""
        post "/api/subjects/#{subj.id}/lectures", params
        response.code.should == "422"
      end

      it "should return code 404 (not found)" do
        post "/api/subjects/007/lectures", params
        response.code.should == "404"
      end
    end

    context "when seminar type" do
      before do
        params.merge!( { :lecture => { :name => "New Lecture seminar type",
                                       :type => "seminar" } } )
      end

      context "when external resource" do
        before do
          params[:lecture].merge!( { :media_title => "Media ttle test", :url => 
                     "http://www.youtube.com/watch?v=kMygTh9NsYE&feature=fvst"})
        end

        it "should return code 201" do
          post "/api/subjects/#{subj.id}/lectures", params
          response.code.should == "201"
        end

        it "should return code 422 (media type not youtube)" do
          params[:lecture][:url] = "http://vimeo.com/17853047"
          post "/api/subjects/#{subj.id}/lectures", params
          response.code.should == "422"
        end

        it "should return original media file name"

        it "should return code 422" do
          params[:lecture][:url] = ""
          post "/api/subjects/#{subj.id}/lectures", params
          response.code.should == "422"
        end

        it "should return code 404" do
          post "/api/subjects/007/lectures", params
          response.code.should == "404"
        end
      end
    end
  end

  context "DELETE a lecture" do

    it "should return code 200" do
      delete "/api/lectures/#{page.id}", params
      response.code.should == "200"
    end

    it "should return code 404" do
      delete "/api/lectures/007", params
      response.code.should == "404"
    end

    it "should remove lectureable(page)" do
      # Detalhe page.subject == subj true
      delete "/api/lectures/#{page.id}", params

      get "/api/subjects/#{subj.id}/lectures", params.merge!({:type => 'page'})
      parse(response.body).should be_empty
    end
  end
end
