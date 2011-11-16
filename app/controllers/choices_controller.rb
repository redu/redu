class ChoicesController < BaseController
  load_resource :exercise
  load_resource :question

  def create
    if params[:choice] && alternative_id = params[:choice][:alternative_id]
      @alternative = @question.alternatives.find(alternative_id)
      @question.choose_alternative(@alternative, current_user)
    end

    @next_question = previous_or_next(params[:commit], @question)

    respond_to do |format|
      format.html do
        redirect_to exercise_question_path(@exercise, @next_question)
      end
    end
  end

  protected

  # Retorna a próxima ou questão anterio baseada na mensagem de commit
  # anteiror ou próxima
  def previous_or_next(commit, current)
    commit ||= ""

    question = if commit.match(/Anterior/)
      current.previous_item
    else
      current.next_item
    end

    question || current
  end
end
