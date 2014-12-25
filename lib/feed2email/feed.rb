require 'feed2email/core_ext'
require 'feed2email/entry'
require 'feed2email/feed_history'
require 'feed2email/feeds'
require 'feedzirra'

module Feed2Email
  class Feed
    def self.config
      Feed2Email.config # delegate
    end

    def self.log(*args)
      Feed2Email.log(*args) # delegate
    end

    def self.process_all
      log :debug, 'Loading feed subscriptions...'
      feed_uris = Feeds.new(File.join(CONFIG_DIR, 'feeds.yml'))

      log :info, "Subscribed to #{'feed'.pluralize(feed_uris.size)}"

      feed_uris.each do |uri|
        log :info, "Found feed #{uri}"
        new(uri).process
      end
    end

    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def process
      if fetched?
        log :debug, 'Feed is fetched'

        if entries.any?
          log :info,
            "Processing #{'entry'.pluralize(entries.size, 'entries')}..."
          process_entries
          history.sync
        else
          log :warn, 'Feed does not have entries'
        end
      else
        log :error, 'Feed could not be fetched'
      end
    end

    private

    def data
      if @data.nil?
        log :debug, 'Fetching and parsing feed...'

        begin
          @data = Feedzirra::Feed.fetch_and_parse(uri,
            :user_agent => "feed2email/#{VERSION}",
            :compress   => true
          )
        rescue => e
          log :error, "#{e.class}: #{e.message.strip}"
          e.backtrace.each {|line| log :debug, line }
        end
      end

      @data
    end

    def config
      Feed2Email.config
    end

    def entries
      @entries ||= data.entries[0..max_entries - 1].map {|entry_data|
        Entry.new(entry_data, uri, title)
      }
    end

    def fetched?
      data.respond_to?(:entries)
    end

    def log(*args)
      Feed2Email::Feed.log(*args) # delegate
    end

    def max_entries
      config['max_entries'].to_i
    end

    def process_entries
      entries.each_with_index do |entry, i|
        # Sleep between entry processing to avoid Net::SMTPServerBusy errors
        sleep(config['send_delay']) if i > 0

        log :info, "Found entry #{entry.uri}"

        if history.old_feed?
          if history.old_entry?(entry.uri)
            log :debug, 'Skipping old entry...'
          else
            log :debug, 'Processing new entry...'

            begin
              entry.process
            rescue => e
              log :error, "#{e.class}: #{e.message.strip}"
              e.backtrace.each {|line| log :debug, line }
            end

            history << entry.uri if e.nil? # no errors
            e = nil
          end
        else
          log :debug, 'Skipping new feed entry...'
          history << entry.uri
        end
      end
    end

    def history
      @history ||= FeedHistory.new(uri)
    end

    def title
      data.title
    end
  end
end
