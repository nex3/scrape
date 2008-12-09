class Entry
  attr_accessor :feed, :url, :time, :link, :text, :created_at

  def initialize(feed)
    self.feed = feed
    self.created_at = Time.now

    @doc = nil until instance_eval(&feed.opts[:once])
    self.text ||= instance_eval(&feed.block)
  end

  def render
    Haml::Engine.new(<<HAML).render(self)
%entry
  %id== \#{URL}/\#{feed.name}/\#{text.hash.to_s(16)}
  %title= time.strftime('%d %B %Y')
  %updated= time.xmlschema
  %content{:type => "html"}&= text
  - if link
    %link{:rel => "alternate", :href => link}/
HAML
  end

  private

  def doc
    @doc ||= Hpricot(open(feed.url))
  end

  def img(el)
    "<img src='#{h el.attributes['src']}' alt='#{h el.attributes['alt']}'>"
  end

  def h(str)
    CGI.escapeHTML str
  end
end
