class ValidationError < StandardError
  attr_accessor :errors

  def initialize(message = nil, errors = nil)
    super(message)
    self.errors = errors
  end
end
