class BooksController < ApplicationController
  def index
    @books = http
  end

  def http(uri)
    require 'net/http'
    params = 'ruby'
    uri = URI.parse("https://library-nippo.herokuapp.com/books")

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10
      headers = { 'Authorization' => 'Bearer secret_key' }
      response = http.get(uri.request_uri, headers)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPRedirection
        'redirect'
      else
        'else'
      end

    rescue IOError => e
      logger.error(e.message)
    rescue TimeoutError => e
      logger.error(e.message)
    rescue JSON::ParserError => e
      logger.error(e.message)
    rescue => e
      logger.error(e.message)
    end
  end
end
