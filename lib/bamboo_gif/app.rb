module BambooGif
  class App
    def call(env)
      Fiber.new do
        req = Rack::Request.new(env)

        begin
          search = Search.new(req.params["q"])

          env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, [search.gif_url]]
        rescue Search::NoResultsError => e
          env['async.callback'].call [404, {'Content-Type' => 'text/plain'}, ['no gifs, bro']]
        end

      end.resume

      throw :async
    end
  end
end
