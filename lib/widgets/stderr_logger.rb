module Widgets
  # A very basic logger that wraps stderr. Used by default by Widgets::Configuration if Rails is not detected.
  class StderrLogger
    def debug(*message) write(:debug, *message); end
    def info(*message)  write(:info,  *message); end
    def error(*message) write(:error, *message); end
    def warn(*message)  write(:warn,  *message); end

    private
    def write(name, *message)
      message.flatten.each { |m| $stderr.puts "#{name}\t#{m}" }
    end
  end
end