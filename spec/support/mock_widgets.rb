module MockWidgets
  def parent_class
    @parent_class ||= Class.new do
      def self.name
        "Parent"
      end

      include Widgets
    end
  end

  def parent
    @parent ||= parent_class.new
  end

  def mock_widget(name, &block)
    @mock_widgets ||= {}
    if @mock_widgets[name]
      @mock_widgets[name].class_eval &block if block_given?
    else
      @mock_widgets[name] = begin
        widget = Class.new(Widget)

        # is there a prettier way to override ::name?
        (class << widget; self; end).send(:define_method, :name) { name }

        widget.class_eval(&block)

        widget
      end
    end
    @mock_widgets[name]
  end
end
