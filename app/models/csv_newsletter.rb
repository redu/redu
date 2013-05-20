# -*- encoding : utf-8 -*-
require 'csv'

class CSVNewsletter < Newsletter
  # Envia newsletter a partir de um arquivo CSV com diversos e-mails. Aceita
  # o caminho para o arquivos CSV (:csv) e caminho para o template a ser usado
  # :template.
  #
  #   newsletter = CSVNewsletter.new(:template => 'newsletter/news.html.erb',
  #                                  :csv => '/path/to/csv')
  #   newsletter.send
  def initialize(options={})
    @csv_path = options[:csv]
    super
  end

  def deliver(&block)
    CSV.open(@csv_path, 'r') do |row|
      row.each do |email|
        block.call(email, {})
      end
    end
  end
end
