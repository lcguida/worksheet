ENV['RACK_ENV'] = 'test'

#Minitest
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require 'coveralls'

Coveralls.wear!

#Application
require_relative '../worksheet.rb'

#Rack::Test includes request simulation methods
include Rack::Test::Methods

def app
  Sinatra::Application
end
