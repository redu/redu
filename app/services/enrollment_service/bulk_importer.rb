module EnrollmentService
  class BulkImporter
    attr_reader :klass, :columns, :default_options

    def initialize(klass, columns, opts={})
      @klass = klass
      @columns = columns
      @default_options = opts
    end

    def import(values, opts={})
      klass.import(columns, values, default_options.merge(opts))

      values
    end
  end
end
