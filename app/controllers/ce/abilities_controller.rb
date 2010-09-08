class AbilitiesController < ApplicationController
  # GET /abilities
  # GET /abilities.xml
  def index
    @abilities = Ability.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @abilities }
    end
  end

  # GET /abilities/1
  # GET /abilities/1.xml
  def show
    @ability = Ability.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ability }
    end
  end

  # GET /abilities/new
  # GET /abilities/new.xml
  def new
    @ability = Ability.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ability }
    end
  end

  # GET /abilities/1/edit
  def edit
    @ability = Ability.find(params[:id])
  end

  # POST /abilities
  # POST /abilities.xml
  def create
    @ability = Ability.new(params[:ability])

    respond_to do |format|
      if @ability.save
        flash[:notice] = 'Ability was successfully created.'
        format.html { redirect_to(@ability) }
        format.xml  { render :xml => @ability, :status => :created, :location => @ability }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ability.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /abilities/1
  # PUT /abilities/1.xml
  def update
    @ability = Ability.find(params[:id])

    respond_to do |format|
      if @ability.update_attributes(params[:ability])
        flash[:notice] = 'Ability was successfully updated.'
        format.html { redirect_to(@ability) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ability.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /abilities/1
  # DELETE /abilities/1.xml
  def destroy
    @ability = Ability.find(params[:id])
    @ability.destroy

    respond_to do |format|
      format.html { redirect_to(abilities_url) }
      format.xml  { head :ok }
    end
  end
end
