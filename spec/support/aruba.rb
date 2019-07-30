require 'rspec/core'
require "aruba/api"

module ArubaHelpers
  def insert_into_file_after(file, pattern, addition)
    path = File.join(expand_path('.'),file)
    content = IO.read(path)
    content.sub!(pattern, "\\0\n#{addition}")
    open(path, 'w') do |f|
      f << content
    end
  end
end

Aruba.configure do |config|
  config.command_search_paths = config.command_search_paths << File.join(File.dirname(__FILE__),'bin')
end

RSpec.configure do |config|
  config.filter_run focus: true

  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Aruba::Api
  config.include ArubaHelpers
  config.before(:each) { setup_aruba }
end