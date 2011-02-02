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
    @mock_widgets[name] ||= begin
      widget = Class.new(Widget, &block)

      # is there a prettier way to override ::name?
      (class << widget; self; end).send(:define_method, :name) { name }

      widget
    end
  end
end
