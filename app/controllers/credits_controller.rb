class CreditsController < BaseController
	load_and_authorize_resource

  def index

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end

  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  def create
    @credit.user = current_user

    if @credit.payment_type == 'boleto'

      @boleto = BancoBrasil.new

      @boleto.cedente = "Guilherme Cavalcanti"
      @boleto.documento_cedente = "12345678912" # CPF, text_field
      @boleto.sacado = "Commprador" # nome, text_field
      @boleto.sacado_documento = "12345678900"
      @boleto.valor = 11135.00
      @boleto.aceite = "S"
      # No número da agência e conta corrente só é preciso colocar os valores
      # antes do '-' o último número é calculado utilizando módulo.
      @boleto.agencia = "0697"   # agência, text_field
      @boleto.conta_corrente = "34595"  # conta corrente, text_field

      # se banco do brasils
      @boleto.convenio = "1238798"
      @boleto.numero_documento = "7777700168"

      @boleto.dias_vencimento = 1
      @boleto.data_documento = Date.today
      @boleto.instrucao1 = "Pagável na rede bancária até a data de vencimento."
      @boleto.instrucao2 = "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)"
      @boleto.instrucao4 = Date.today
      @boleto.instrucao5 = "Após vencimento pagável somente nas agências do Banco do Brasil"
      # Endereço do comprador
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
