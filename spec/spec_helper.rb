
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../app/models')
$:.unshift(File.dirname(__FILE__) + '/../../basic_skin/lib')

require 'rubygems'
require 'rspec'
require 'active_support/all'

Dir[File.dirname(__FILE__) + '/../app/models/*'].each{|file| require file}

RSpec.configure do |config|
  config.mock_with :rspec
end
