class AnalyticsDashboardController < BaseController
  respond_to :json

  def dashboard
    respond_to do |format|
      format.html { render :layout => 'clean' }
    end
  end

  def signup_by_date
    startd = Date.new(2011,02,05)
    endd = Date.today

    @by_signup = Analytics.signup_count_by_date(startd, endd)
    @graph = plot("cadastro por dia", "cadastros", @by_signup)

    respond_to  do |format|
      format.html { render :signup_by_date }
    end
  end

  def environment_by_date
    startd = Date.new(2011,02,05)
    endd = Date.today

    @data = Analytics.environment_count_by_date(startd, endd)
    @graph = plot("criação de AVA por dia", "número de AVAs", @data)

    respond_to  do |format|
      format.html { render :signup_by_date }
    end
  end

  def course_by_date
    startd = Date.new(2011,02,05)
    endd = Date.today

    @data = Analytics.course_count_by_date(startd, endd)
    @graph = plot("criação de Cursos por dia", "número de cursos", @data)

    respond_to  do |format|
      format.html { render :signup_by_date }
    end
  end

  def post_by_date
    startd = Date.new(2011,02,05)
    endd = Date.today

    @data = Analytics.post_count_by_date(startd, endd)
    @graph = plot("Postagens  por dia", "número de posts", @data)

    respond_to  do |format|
      format.html { render :signup_by_date }
    end
  end


  private

  def plot(name, serie_name, data)
    LazyHighCharts::HighChart.new do |f|
      f.chart(:zoomType => 'x')
      f.title({:text => name})
      f.plotOptions({
        :area => {
          :lineWidth => 1,
          :shadow => false
        }
      })
      f.series(:name=>'Cadastros',
               :type => 'area',
               :pointInterval => 1.day * 1000,
               :pointStart => data.first[0].to_time.to_i * 1000,
               :data => data.collect(&:last).flatten)
    end

  end
end
