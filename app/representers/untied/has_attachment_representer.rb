# -*- encoding : utf-8 -*-
module Untied
  module HasAttachmentRepresenter
    # Este representa adiciona um property :avatar_url que retorna a URL completa
    # de um attachment do Paperclip. É assumido que a entidade a ser representadada
    # possua um attachment (has_attachment) com o nome :avatar.
    extend ActiveSupport::Concern

    included do
      property :fully_fladged_avatar_url, :from => :avatar_url
    end

    def fully_fladged_avatar_url
      self.avatar.url(:original)
    end
  end
end
