module Widgets
  # Raised when processing or subprocessing cannot take place.
  class ProcessingError < StandardError
  end

  # Raised when subprocessing is attempted on a widget's return value when the value does not support it.
  class SubprocessingNotSupported < StandardError
  end

  # Removed, and only kept for the tests' use.
  class InvalidClassName #:nodoc:
  end
end
