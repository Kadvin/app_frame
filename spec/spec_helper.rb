$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../app/models')

require 'rubygems'
require 'rspec'

RAILS_ENV = 'test'

RSpec.configure do |config|
  config.mock_with :rspec
end
