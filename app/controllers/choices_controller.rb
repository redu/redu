class ChoicesController < BaseController
  load_resource :exercise
  load_resource :question

  def create
    result = @exercise.result_for(current_user, false)

    if can?(:update, result) && alternative_id = alternative_if_exists(params)
      @alternative = @question.alternatives.find(alternative_id)
      @question.choose_alternative(@alternative, current_user)
    end

    @next_question = previous_or_next(params[:commit], @question)

    respond_to do |format|
      format.html do
        if @next_question
          redirect_to exercise_question_path(@exercise, @next_question)
        else
          redirect_to \
            edit_exercise_result_path(@exercise, result)
        end
      end
    end
  end

  protected

  # Retorna a próxima ou questão anterio baseada na mensagem de commit
  # anteiror ou próxima
  def previous_or_next(commit, current)
    commit ||= ""

    if commit.match(/Anterior/)
      current.previous_item
    else
      current.next_item
    end
  end

  def alternative_if_exists(params)
    return params[:choice][:alternative_id] if params[:choice]
  end
end
