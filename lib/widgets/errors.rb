module Widgets
  # Raised when processing or subprocessing cannot take place.
  class ProcessingError < StandardError
  end

  # Raised when a widget is declared to affect a class but the class name is not a Symbol.
  class InvalidClassName < ArgumentError
  end
end