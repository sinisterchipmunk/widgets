class AncestryMatcher
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    target.class.ancestors.include?(@expected)
  end

  def failure_message
    "expected #{target} to inherit from #{@expected}"
  end

  def negative_failure_message
    "expected #{target} to not inherit from #{@expected}"
  end
end
