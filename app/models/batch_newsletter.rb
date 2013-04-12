class BatchNewsletter < Newsletter
  # Envia e-mail em batch para os usuários passados na inicialização. Deve
  # ser inicializado com opção :users sendo uma instância de ARel.
  #
  #   arel = User.select("email").where(:role => :admin)
  #   newsletter = BatchNewsletter(:template => "foo/bar.html.erb", :users => arel)
  #   newsletter.send(:subject => "Hey!")
  #
  # Utiliza o método .find_each (batch de 1000).
  def initialize(options={})
    @users = options.delete(:users)
    super
  end

  def deliver(&block)
    @users.find_each do |user|
      block.call(user.email, {:user => user})
    end
  end
end
