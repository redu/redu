class VideosController < BaseController
  
  def index
    @videos = Video.find :all
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    if @video.save
      @video.convert # TODO verificar @video.failure
      flash[:notice] = 'O video foi uplodeado!'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def show
    @video = Video.find(params[:id])
  end
  
  def destroy
    @video = Video.find(params[:id])
    @video.destroy
    redirect_to :action => 'index'
  end

end
