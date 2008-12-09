require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'haml'
require 'hpricot'
require 'cgi'
require 'active_support/core_ext/string'

dir = File.dirname(__FILE__)
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)
require 'entry'
require 'feeds'

get '/:comic' do
  content_type 'application/atom+xml', :charset => 'utf-8'
  Feeds[params['comic']].render
end
