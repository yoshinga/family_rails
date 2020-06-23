class BooksController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    path = 'books'
    @books = http(path)["data"]
    binding.pry
  end

  def new

  end

  def create
    path = 'books'
    @book = http_post(
      path,
      book_params["title"],
      book_params["price"],
      book_params["author"],
      book_params["link"],
    )
  end

  private

  def http_post(path, title, price, author, link)
    uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
    headers = { 'Authorization' => 'Bearer secret_key' }

    params = {
      'owner_id' => 1,
      'publisher_id' => 1,
      'rent_user_id' => nil,
      'purchaser_id' => nil,
      'status' => '0',
      'title' => title,
      'price' => price,
      'author' => author,
      'link' => link,
      'latest_rent_date' => '',
      'return_date' => '',
      'purchase_date' => '',
      'publication_date' => '',
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data(params)

      response = http.request(request)

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

  def http(path)
    uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")

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
      else
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

  def book_params
    params.permit(:title, :price, :author, :link)
  end
end
