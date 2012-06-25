require 'request_spec_helper'

describe 'CourseInvitationAcceptances' do

  before do
    @kenobi = Factory(:user, :login => 'ObiWan', :first_name => 'Obi-Wan',
                      :last_name => 'Kenobi', :email => 'kenobi@masters.jedi.com')
    @anakin = Factory(:user, :login => 'Anakin', :first_name => 'Anakin',
                      :last_name => 'Skywalker', :email =>'anakin@apprentices.jedi.com')
    @course = Factory(:course, :name => 'Jedi101',
                      :environment => Factory(:environment, :name => 'JTraining',
                                              :plan => Factory(:plan), 
                                              :owner => @kenobi))
    @course.invite @anakin
  end

  context 'when invitation receiver is logged' do
    before do
      login_as @anakin
    end

    it 'should show warning in the user\'s home view' do
      page.should have_content 'foi convidado para o curso'
      page.should have_content @course.name
      page.should have_button 'Aceitar'
      page.should have_button 'Recusar'
    end

    it 'should show warning in the course page' do
      visit environment_course_path(@course.environment, @course)
      page.should have_content 'já foi convidado'
    end

    context 'and accepts the invitation' do
      before do
        click_button 'Aceitar'
      end

      it 'should asynchronously hide the invitation warning', :js => true do
        assert_that_element_was_hidden "#requisition-#{(@anakin.get_association_with @course).id}"
      end

      it 'should enroll the receiver' do
        @course.users.should include @anakin
      end
    end
  end

  private

  def assert_that_element_was_hidden(element)
    sleep 2
    find(element).visible?.should be_false
  end

end
