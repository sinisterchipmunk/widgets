# Bootstrap file for Rails projects. Not loaded if Rails can't be found.

module Widgets
  if defined?(Rails::Railtie)
    # Rails 3
    class Railtie < Rails::Railtie
      config.to_prepare do
        Widgets.load!
      end
    end
  else
    # Rails 2
    Rails.configuration.to_prepare do
      Widgets.load!
    end
  end
end
