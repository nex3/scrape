#!/usr/bin/env ruby

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

def comics_dot_com(name, options = {})
  feed(name, "http://comics.com/#{options[:url] || name}",
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
comics_dot_com :arlo_and_janis, :url => 'arlo&janis'

feed :dominic_deegan, 'http://dominic-deegan.com/' do
  self.time = Time.parse((doc/'.comic .date').first.inner_text)
  self.link = "/view.php?date=#{time.strftime('%Y-%m-%d')}"
  img((doc/'.comic img').first)
end

undated_feed :girls_with_slingshots, 'http://daniellecorsetto.com/gws.html' do
  img = (doc/'#gwsblog img').first
  src = img.attributes['src']
  check_updated src
  src =~ %r{^images/gws/GWS(\d+).jpg$}

  self.link = $1 ? "/archive.php?comic=#{$1}" : "/gws.html"
  (doc/'#gwsblog').html
end

undated_feed :elsie_hooper, 'http://www.elsiehooper.com/todaysserial.htm' do
  ps = doc/'body > div.font > p'
  self.title = ps.first.inner_text
  img = (ps[1]/'img').first
  src = img.attributes['src']
  check_updated src

  src =~ %r{^/comics_/elsieh(\d+)}
  self.link = "/todaysserial.htm"
  img(img)
end

get '/:comic' do
  content_type 'application/atom+xml', :charset => 'utf-8'
  Feeds[params['comic']].render
end
