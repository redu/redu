class NameService
  attr_accessor :min_length ,:max_length

  def initialize(opts)
    @max_length = opts[:max_length]
    @min_length = opts[:min_length]
  end

  def valid_login(opts)
    login = opts[:nickname] || opts[:login]
    first_name = opts[:first_name]
    last_name = opts[:last_name]

    valid_login = (login || "#{first_name}#{last_name}").parameterize

    valid_login = truncate(valid_login)
    inflate(valid_login)
  end

  private

  def truncate(name)
    max = max_length - 4
    "#{name.slice(0..max)}#{SecureRandom.hex(2)}"
  end

  def inflate(name)
    inflation_number = min_length - name.length
    if inflation_number > 0
      "#{name}#{SecureRandom.hex(inflation_number)}"
    else
      name
    end
  end
end
