class CreditsController < BaseController
  def index
    
    @credit = Credit.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end
  
  def show
    @credit = Credit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end
  
  def create
    @credit = Credit.new(params[:credit])
    @credit.user_id = current_user.id
    
    if @credit.payment_type == 'boleto'
      
      @boleto = BancoBrasil.new
      
      @boleto.cedente = "Kivanio Barbosa"
      @boleto.documento_cedente = "12345678912"
      @boleto.sacado = "Claudio Pozzebom"
      @boleto.sacado_documento = "12345678900"
      @boleto.valor = 11135.00
      @boleto.aceite = "S"
      @boleto.agencia = "4042"
      @boleto.conta_corrente = "61900"
      
      # se banco do brasil
      @boleto.convenio = "1238798"
      @boleto.numero_documento = "7777700168"
      
      @boleto.dias_vencimento = 5
      @boleto.data_documento = "2008-02-01".to_date
      @boleto.instrucao1 = "Pagável na rede bancária até a data de vencimento."
      @boleto.instrucao2 = "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)"
      @boleto.instrucao3 = "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006"
      @boleto.instrucao4 = "NÃO RECEBER APÓS 15/11/2006"
      @boleto.instrucao5 = "Após vencimento pagável somente nas agências do Banco do Brasil"
      @boleto.instrucao6 = "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO"
      @boleto.sacado_endereco = "Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT"
    
    
      headers['Content-Type']='application/pdf'
      send_data @boleto.to('pdf'), :filename => "boleto_bb.pdf" and return
      
      
    elsif @credit.payment_type == 'teste'
      
      @credit.state = 'approved'
      
    end

    respond_to do |format|
      if @credit.save
        flash[:notice] = 'Credito comprado com sucesso'
        format.html { redirect_to(@credit) }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    
    end
  end
  
end
