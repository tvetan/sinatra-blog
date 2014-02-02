ENV["RACK_ENV"] = "test"

require 'mongoid'
require 'bundler/setup'
require './app'

require 'rack/test'
require 'minitest/autorun'

Dir[File.join("test", "support", "**", "*.rb")].each do |file|
  require File.expand_path(file)
end

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    BlogApplication
  end

  before  do
    #Todo.db.clear
  end
end