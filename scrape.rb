require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'haml'
require 'hpricot'
require 'cgi'
require 'active_support'

dir = File.dirname(__FILE__)
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)
require 'entry'
require 'feeds'

def comics_dot_com(name)
  feed(name, "http://comics.com/#{name}",
       :once => lambda { !(doc/'title').inner_text.include?('404') }) do
    self.time = Time.parse((doc/'.STR_Date').first.inner_text)
    el = (doc/'.STR_StripImage').first
    self.link = el.attributes['href']
    img((el/'img').first)
  end
end

comics_dot_com :frazz
comics_dot_com :rose_is_rose
comics_dot_com :get_fuzzy

get '/:comic' do
  content_type 'application/atom+xml', :charset => 'utf-8'
  Feeds[params['comic']].render
end
