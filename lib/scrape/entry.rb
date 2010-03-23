require 'cgi'
require 'hpricot'
require 'open-uri'
require 'haml'

module Scrape
  class Entry
    attr_accessor :feed, :url, :time, :link, :title, :text, :created_at

    def initialize(feed)
      self.feed = feed
      self.created_at = Time.now

      @doc = nil until instance_eval(&(feed.opts[:once] || proc {true}))
      self.text ||= instance_eval(&feed.block)
    rescue Exception => e
      self.time = Time.now
      self.text = "<h1>Error: #{h e.class}</h1><h2>#{h e.message}</h2>"
    end

    def render
      Haml::Engine.new(<<HAML).render(self)
%entry
  %id== \#{URL}/\#{feed.name}/\#{text.hash.to_s(16)}
  %title= title || time.strftime('%d %B %Y')
  %updated= time.xmlschema
  %content{:type => "html"}&= text
  - if link
    %link{:rel => "alternate", :href => link}/
HAML
    end

    private

    def doc
      times = 0
      @doc ||= Hpricot(open(feed.url))
    rescue Errno::ECONNREFUSED => e
      times += 1
      retry if times < 3
      raise e
    end

    def img(el)
      "<img src='#{h el.attributes['src']}' alt='#{h el.attributes['alt'] || ''}'>"
    end

    def h(str)
      CGI.escapeHTML str.to_s
    end

    def check_updated(token)
      throw :not_updated if feed.data.last_token == token
    end

    def normalize_attrs!(el)
      el.attributes.each {|k, v| el.set_attribute(k.downcase, v)} if el.is_a?(Hpricot::Elem)
      el.each_child {|el2| normalize_attrs!(el2)} if el.respond_to?(:each_child)
    end
  end
end
