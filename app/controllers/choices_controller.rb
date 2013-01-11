class ChoicesController < BaseController
  respond_to :js

  load_resource :exercise
  load_resource :question

  def create
    @result = @exercise.result_for(current_user, false)

    if can?(:update, @result) && alternative_id = alternative_if_exists(params)
      @alternative = @question.alternatives.find(alternative_id)
      @question.choose_alternative(@alternative, current_user)
    end

    respond_to do |format|
      format.js do
        if params[:commit].nil?
          render :partial => "questions/choice_form", :locals => locals_form
        else
          render :js => "window.location = '#{ edit_exercise_result_path(@exercise, @result) }'"
        end
      end
    end
  end

  protected

  def alternative_if_exists(params)
    return params[:choice][:alternative_id] if params[:choice]
  end

  def locals_form
    review = !@result.nil? || @can_manage_lecture
    choice = @question.choices.
      first(:conditions => { :user_id => current_user.id}) || @question.choices.build

    hash = { :exercise => @exercise, :question => @question,
             :first => @question.first_item, :last => @question.last_item,
             :review => review, :choice => choice, :result => @result }
    hash
  end
end
