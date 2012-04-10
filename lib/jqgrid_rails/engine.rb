module JqGridRails
  class Engine < ::Rails::Engine
    config.after_initialize do
      %w(escape_mappings jqgrid_rails_controller jqgrid_rails_generators 
           jqgrid_rails_helper jqgrid_rails_helpers jqgrid_rails_view 
           jqgrid_rails_writeexcel jqgrid jqgrid_url_generator).each do |file|
        require_relative file
      end
    end
  end
end
