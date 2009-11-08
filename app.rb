#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'

require 'hpricot'
require 'open-uri'

require File.dirname(__FILE__) + '/lib/scrape'

def comics_dot_com(name, options = {})
  Scrape(name, "http://comics.com/#{options[:url] || name}",
       :once => lambda { !(doc/'title').inner_text.include?('404') }) do
    self.time = Time.parse((doc/'.STR_Date').first.inner_text)
    el = (doc/'.STR_StripImage').first
    self.link = el.attributes['href']
    img((el/'img').first)
  end
end

def gocomics(name, options = {})
  Scrape(name, "http://www.gocomics.com/#{options[:url] || name}/") do
    self.time = Time.parse((doc/'.feature-nav li').first.inner_text)
    self.link = (doc/'.feature h1 a').first.attributes['href']
    img((doc/'.feature_item img').first)
  end
end

comics_dot_com :frazz
comics_dot_com :rose_is_rose
comics_dot_com :get_fuzzy
comics_dot_com :arlo_and_janis, :url => 'arlo&janis'

gocomics :non_sequitur, :url => 'nonsequitur'

Scrape :dominic_deegan, 'http://dominic-deegan.com/' do
  self.time = Time.parse((doc/'.comic .date').first.inner_text)
  self.link = "/view.php?date=#{time.strftime('%Y-%m-%d')}"
  img((doc/'.comic img').first)
end

Scrape "8_bit_theater", 'http://www.nuklearpower.com/8-bit-theater/' do
  prev_doc = Hpricot(open((doc/'.navbar-previous a').first.attributes['href']))
  self.link = (prev_doc/'.navbar-next a').first.attributes['href']
  self.time = Time.parse(self.link[/[0-9]+\/[0-9]+\/[0-9]+/])

  img = (doc/'#comic img').first
  self.title = img.attributes['title']
  img(img)
end

Scrape.undated :girls_with_slingshots, 'http://daniellecorsetto.com/gws.html' do
  img = (doc/'#gwsblog img').first
  src = img.attributes['src']
  check_updated src
  src =~ %r{^images/gws/GWS(\d+).jpg$}

  self.link = $1 ? "/archive.php?comic=#{$1}" : "/gws.html"
  (doc/'#gwsblog').html
end

Scrape.undated :elsie_hooper, 'http://www.elsiehooper.com/todaysserial.htm' do
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
  Scrape.feeds[params['comic']].render
end
