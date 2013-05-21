# -*- encoding : utf-8 -*-
module ScribdSpecHelper
  def mock_scribd_api
    @scribd_user = mock("scribd_user")
    Scribd::User.stub!(:login).and_return(@scribd_user)
    @scribd_response = mock('scribd_response', :doc_id => "doc_id",
                            :access_key => "access_key")
    @scribd_user.stub(:upload).and_return(@scribd_response)
    @scribd_user.stub(:find_document).and_return(@scribd_response)
  end
end
