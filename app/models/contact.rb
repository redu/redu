class Contact
  # include Validatable # Gem para validar modelos não persistentes

  # ACCESSORS
  attr_accessor :name, :email, :kind, :subject, :body

  # VALIDATIONS
  ## validates_presence_of :name, :message => "Seu nome é necessário."
  ## validates_presence_of :email, :message => "Seu e-mail é necessário."
  ## validates_presence_of :body, :message => "A mensagem é necessária."
  ## validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i,
  ##   :message => "E-mail inválido."

  ## def deliver
  ##   if valid?
  ##     UserNotifier.contact_redu(self).deliver
  ##   else
  ##     false
  ##   end
  ## end
end
