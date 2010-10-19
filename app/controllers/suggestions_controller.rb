class SuggestionsController < BaseController
  # GET /suggestions
  # GET /suggestions.xml
  def index
    @suggestions = Suggestion.paginate(:all, :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @suggestions }
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.xml
  def show
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @suggestion }
    end
  end

  # GET /suggestions/new
  # GET /suggestions/new.xml
  def new
    @suggestion = Suggestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @suggestion }
    end
  end

  # GET /suggestions/1/edit
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # POST /suggestions
  # POST /suggestions.xml
  def create
    @suggestion = Suggestion.new(params[:suggestion])

    respond_to do |format|
      if @suggestion.save
        flash[:notice] = 'Sugestão adicionada com sucesso'
        @suggestion.update_attribute(:yes, 0)
        @suggestion.update_attribute(:no, 0)

        format.html { redirect_to suggestions_path }
        format.xml  { render :xml => @suggestion, :status => :created, :location => @suggestion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @suggestion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /suggestions/1
  # PUT /suggestions/1.xml
  def update
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      if params[:commit] == 'Sim'
        @suggestion.update_attribute(:yes, @suggestion.yes + 1)
        flash[:notice] = 'Votação incluida'
        format.html { redirect_to suggestions_path }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Votação incluida'
        @suggestion.update_attribute(:no, @suggestion.no + 1)
        format.html { redirect_to suggestions_path }
        format.xml  { head :ok }
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.xml
  def destroy
    @suggestion = Suggestion.find(params[:id])
    @suggestion.destroy

    respond_to do |format|
      format.html { redirect_to(suggestions_url) }
      format.xml  { head :ok }
    end
  end

end
