require 'uri'
require 'feed2email/http_fetcher'

module Feed2Email
  class RedirectionChecker
    def initialize(url)
      @url = url
    end

    attr_reader :location

    def permanently_redirected?
      check
      !location.nil? && code == '301'
    end

    private

    def check
      fetcher = HTTPFetcher.new(url, max_redirects: 0, headers_only: true)

      begin
        fetcher.response
      rescue HTTPFetcher::TooManyRedirects => e
        @location = URI.parse(e.response['location']).to_s
      rescue HTTPFetcher::HTTPFetcherError # order is significant
        # @location remains nil
      end

      @code = fetcher.response.code
    end

    attr_reader :code, :url
  end
end
