URL = "http://scrape.nex-3.com/"

class Feed < Struct.new(:name, :url, :opts, :block)
  def render
    Haml::Engine.new(<<HAML).render(self)
!!! XML
%feed{:xmlns => "http://www.w3.org/2005/Atom", 'xml:base' => url}
  %title= name.titleize
  %link= url
  %updated= entry.time.xmlschema
  %id== \#{URL}/\#{name}

  = entry.render
HAML
  end

  def entry
    return @entry if @entry && Time.now - @entry.created_at < 1.hour
    @entry = Entry.new(self)
  end
end

Feeds = {}
def feed(name, url, opts = {}, &block)
  name = name.to_s
  Feeds[name] = Feed.new(name, url, opts, block)
end
