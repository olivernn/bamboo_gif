require 'fiber'
module BambooGif
  class Search

    class NoResultsError < StandardError ; end

    GIF_BIN_URL = "http://www.gifbin.com/tag/"

    def initialize(query)
      @query = query
      fetch_results
    end

    attr_reader :query, :response, :gif_url

    private

    def url
      GIF_BIN_URL + query + "/"
    end

    def fetch_results
      fiber = Fiber.current

      request = EM::HttpRequest.new(url).get

      request.callback { fiber.resume :ok, request.response }
      request.errback { fiber.resume :error, nil }

      status, @response = Fiber.yield

      if status == :ok
        parse_response
      else
        raise NoResultsError
      end
    end

    def parse_response
      gifs = Nokogiri::HTML(response).css('.thumb-cell img').to_a
      raise NoResultsError unless gifs.any?
      @gif_url = gifs.sample['src'].gsub('tn_', '')
    end
  end  
end
