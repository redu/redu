class CreditsController < ApplicationController
  def index
    @balance = 40
    @credit = Credit.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end
  
  def create
    @credit = Credit.new(params[:credit])
    @credit.user = current_user

    respond_to do |format|
      if @credit.save
        flash[:notice] = 'Credit was successfully created.'
        format.html { redirect_to(@credit) }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
