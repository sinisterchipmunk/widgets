module Widgets
  module ClassMethods
    def widget_processing_method_name
      @widget_processing_method_name ||= :process
    end

    def widget_processing_method_name=(name)
      if !method_defined?(name)
        module_eval(<<-end_code, __FILE__, __LINE__ + 1)
          def #{name}(&block)
            raise Widgets::ProcessingError, "Cannot perform processing: no block specified" unless block_given?

            # arity == -1 is bug 574 in Ruby 1.8 -- should be 0. It's of no consequence in this case.
            (block.arity == 0 || block.arity == -1) ? instance_eval(&block) : block.call(self)
          end
        end_code
      end

      @widget_processing_method_name = name
    end

    # By default, Widget processing and subprocessing is triggered with the #process method. Use this
    # to enable a different method.
    #
    # Ex:
    #  class MyObject
    #    include Widgets
    #    process_with :setup
    #  end
    #
    #  # ...
    #  MyObject.new.setup do
    #    # ...
    #  end
    #
    def process_with(name)
      self.widget_processing_method_name = name
    end
  end
end
