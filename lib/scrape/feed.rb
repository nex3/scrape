require 'ostruct'

URL = "http://scrape.heroku.com/"

module Scrape
  class Feed < Struct.new(:name, :url, :opts, :block, :data)
    def render
      Haml::Engine.new(<<HAML).render(self)
!!! XML
%feed{:xmlns => "http://www.w3.org/2005/Atom", 'xml:base' => url}
  %title&= name.titleize
  %link&= url
  %updated&= entry.time.xmlschema
  %id&== \#{URL}/\#{name}

  = entry.render
HAML
    end

    def entry
      return @entry if @entry && Time.now - @entry.created_at < 1.hour
      @entry = Entry.new(self)
    end
  end
end
