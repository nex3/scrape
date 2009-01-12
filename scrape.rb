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

feed :dominic_deegan, 'http://dominic-deegan.com/' do
  self.time = Time.parse((doc/'#table1 strong nobr').first.inner_text)
  self.link = "/view.php?date=#{time.strftime('%Y-%m-%d')}"
  img((doc/'#table1 img').first)
end

feed :girls_with_slingshots, 'http://daniellecorsetto.com/gws.html' do
  self.time = Time.now # Yep, it really has no date listed
  img = (doc/'#gwsblog img').first
  src = img.attributes['src']
  break feed.data.last_text if feed.data.last_src == src
  feed.data.last_src = src
  src =~ %r{^images/gws/GWS(\d+).jpg$}

  self.link = $1 ? "/archive.php?comic=#{$1}" : "/gws.html"
  feed.data.last_text = (doc/'#gwsblog').html
end

get '/:comic' do
  content_type 'application/atom+xml', :charset => 'utf-8'
  Feeds[params['comic']].render
end
