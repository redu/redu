module Api
  class Canvas < ActiveRecord::Base
    belongs_to :user
    belongs_to :client_application
    # Remover depois que testar o script, lembrar de criar uma migration para remover no banco de dados
    belongs_to :container, :polymorphic => true
    has_one :lecture, :as => :lectureable

    validates_presence_of :client_application
    validates :url, :url => true, :allow_nil => true

    def current_url(querystring={})
      raw_url = self.url || self.client_application.try(:url)

      decorate_url(raw_url, querystring)
    end

    def current_name
      self.name || self.client_application.try(:name)
    end

    private

    def decorate_url(url, querystring={})
      return url if querystring.empty? || url.nil?

      parsed = Addressable::URI.parse(url)
      current_qs = parsed.query_values || {}
      parsed.query_values = current_qs.merge(querystring)
      parsed.to_s
    end
  end
end
