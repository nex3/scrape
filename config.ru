require 'rubygems'
require 'sinatra'

root_dir = File.dirname(__FILE__)

Sinatra::Application.default_options.merge!(
  :app_file => File.join(root_dir, 'scrape.rb'),
  :run => false
)

run Sinatra.application
