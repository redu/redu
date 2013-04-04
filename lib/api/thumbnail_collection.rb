module Api
  module ThumbnailCollection
    # Provê collection para o representer do modelo com todos os thumbnails.
    extend ActiveSupport::Concern

    included do
      collection :thumbnails
    end

    module InstanceMethods
      def thumbnails
        self.avatar.styles.keys.collect do |thumb_size|
          height = width = thumb_size.to_s.gsub('thumb_', '')
          { :size => "#{width}x#{height}",
            :href => self.avatar.url(thumb_size) }
        end
      end
    end

  end
end
