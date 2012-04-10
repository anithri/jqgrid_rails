module JqGridRails
  class Railtie < Rails::Railtie

    rake_tasks do
      require 'jqgrid_rails/tasks'
    end

    # We do all our setup in here
    config.to_prepare do
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
        :plugins => %w(/javascripts/grid.locale-en.js /javascripts/jquery.jqGrid.min.js)
      )
      ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
        :plugins => %w(/stylesheets/ui.jqgrid.css)
      )
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
        :jqgrid_rails => %w(/javascripts/grid.locale-en.js /javascripts/jquery.jqGrid.min.js)
      )
      ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
        :jqgrid_rails => %w(/stylesheets/ui.jqgrid.css)
      )
      Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each do |file|
        unless(%w(railtie.rb tasks.rb version.rb).find{|skip| file.ends_with?(skip)})
          require file
        end
      end
    end
  end
end
