#!/usr/bin/env ruby

###
### RubyGems Specification file for app_frame
###
### $Rev: 1 $
### $Release: 0.0.1 $
### Copyright(c) 2010 kadvin.com all rights reserved.
###

require 'rubygems'
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "app_frame/version"

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = 'app_frame'
  s.version     = AppFrame::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w[Kadvin]
  s.email       = "me@kadvin.com"
  s.platform    = Gem::Platform::RUBY
  s.homepage    = 'http://github.com/Kadvin/app_frame'
  s.summary     = "A frame which can provide unified, configurable, skinable WEB UI."
  s.description = <<-'END'
    A frame which can provide unified, configurable, skinable WEB UI in Application Framework.
  END

  ## files
  files = []
  files += Dir.glob('lib/**/*')
  files += Dir.glob('test/**/*')
  files += %w[README ChangeLog app_frame.gemspec]
  s.files       = files.delete_if { |path| path =~ /\.(svn|git)/ }
  s.files       = files

  s.rubygems_version   = "1.3.7"
  s.rubyforge_project  = "rspec"
  s.default_executable = "rspec"

  s.require_path     = "lib"

  s.post_install_message = %Q{**************************************************

  Thank you for use app-frame!

**************************************************
}

end
