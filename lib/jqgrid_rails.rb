require 'jqgrid_rails/version'
require 'jqgrid_rails/escape_mappings'

if(defined?(Rails))
  if ::Rails.version >= '3.1'
    require 'jqgrid_rails/engine'
  elsif(defined?(Rails::Railtie))
    require 'jqgrid_rails/railtie'
  else
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
      :jqgrid_rails => %w(/jqgrid_rails/vendor/assets/javascripts/grid.locale-en.js /jqgrid_rails/vendor/assets/javascripts/jquery.jqGrid.min.js)
    )
    ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
      :jqgrid_rails => %w(/jqgrid_rails/vendor/assets/stylesheets/ui.jqgrid.css)
    )
    Dir.glob(File.join(File.dirname(__FILE__), 'jqgrid_rails', '*.rb')).each do |file|
      unless(%w(railtie.rb tasks.rb version.rb).find{|skip| file.ends_with?(skip)})
        require file
      end
    end
  end
end
