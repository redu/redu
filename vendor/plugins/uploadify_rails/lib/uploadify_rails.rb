# UploadifyRails
module UploadifyRails
  require 'uploadify_rails_helper'
  ActionView::Base.send :include, UploadifyRailsHelper  
end