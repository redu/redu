module EnrollmentService
  class BulkMapper
    attr_reader :klass, :columns, :default_options

    def initialize(klass, columns, opts={})
      @klass = klass
      @columns = columns
      @default_options = opts
    end

    def insert(values, opts={})
      choosed_columns = opts.delete(:columns) || columns
      klass.import(choosed_columns, values, default_options.merge(opts))

      values
    end
  end
end
