class Newsletter
  # Classe abstrata que lida com o envio de newsletter utilizando o
  # NewsletterMailer.
  #
  # Classes filhas devem implementar o método #deliver.
  def initialize(options={})
    @template = options.delete(:template)
  end

  # Deve ser implementado nas classes filhas. Aceita um bloco que deve ser invocado
  # com o os parâmetros email e um hash de opções que será passado para o mailer.
  #
  # Exemplo:
  #
  #   def deliver(&block)
  #     @emails.each do |email|
  #       block.call(email, {})
  #     end
  #   end
  def deliver(&block); end

  # Delega o controle para o método #deliver e envia o e-mail.
  def send
    deliver do |email, options|
      mailer.newsletter(email, { :template => @template }.merge(options)).deliver
    end
  end

  protected

  def mailer
    NewsletterMailer
  end
end
