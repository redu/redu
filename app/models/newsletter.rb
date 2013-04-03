class Newsletter
  # Classe abstrata que lida com o envio de newsletter utilizando o
  # NewsletterMailer.
  #
  # A estratégia utilizada para iterar sobre a lista de e-mails deve ser
  # implementada nas classes filhas sobrescrevendo o método #deliver.
  def initialize(options={})
    @template = options.delete(:template)
  end

  # As classes filhas devem implementar o método #deliver que é responsável
  # por iterar a lista de e-mails e invocar o bloco recebido por parâmetro
  # sempre que um e-mail precisar ser enviado.
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
  def send(mail_options={})
    deliver do |email, options|
      opts = { :template => @template }.merge(options.merge(mail_options))
      mailer.newsletter(email, opts).deliver
    end
  end

  protected

  def mailer
    NewsletterMailer
  end
end
