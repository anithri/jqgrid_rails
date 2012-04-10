$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jqgrid_rails/version'
Gem::Specification.new do |s|
  s.name = 'jqgrid_rails'
  s.version = JqGridRails::VERSION
  s.summary = 'jqGrid for Rails'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'http://github.com/chrisroberts/jqgrid_rails'
  s.description = 'jqGrid for Rails'
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE.rdoc', 'CHANGELOG.rdoc']
  s.add_dependency 'rails_javascript_helpers', '~> 1.4'
  s.add_dependency 'rails', '>= 2.3'
  s.add_dependency 'writeexcel', '>= 0.6.12'
  s.files = Dir.glob("**/*")
end
