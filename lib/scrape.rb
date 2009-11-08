require 'active_support'

dir = File.dirname(__FILE__)
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)
require 'scrape/entry'
require 'scrape/feed'

module Scrape
  class << self
    attr_accessor :feeds

    def scrape(name, url, opts = {}, &block)
      name = name.to_s
      feeds[name] = Feed.new(name, url, opts, block, OpenStruct.new)
    end

    def undated(*args, &block)
      scrape(*args) do
        self.time = Time.now
        feed.data.last_text = catch(:not_updated) {instance_eval(&block)} ||
          feed.data.last_text
      end
    end
  end
  self.feeds = {}
end

def Scrape(*args, &block)
  Scrape.scrape(*args, &block)
end
