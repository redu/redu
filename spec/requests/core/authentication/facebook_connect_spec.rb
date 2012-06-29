require 'request_spec_helper'

describe 'FacebookConnect' do

	it 'allows user register via facebook' do
		visit application_path
		click_link 'Logar com Facebook'
		page.should have_content 'conta foi criada com'
	end

end