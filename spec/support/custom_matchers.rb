module CustomMatchers
  def inherit(*what)
    AncestryMatcher.new(*what)
  end
end