require 'net/http'
class PublishersController < ApplicationController
  def new; end

  def create
    path = 'publishers'
    @publisher = http_post(
      path,
      publisher_params["publisher"],
    )
  end

  private

  def http_post(path, publisher)
    uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
    headers = { 'Authorization' => 'Bearer secret_key' }

    params = {
      'publisher' => publisher,
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data(params)

      res = http.request(request)

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

  def publisher_params
    params.permit(:publisher)
  end
end
