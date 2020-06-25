class BooksController < ApplicationController
  # before_action :authenticate_user!
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    path, action = 'books', 'get'
    binding.pry
    @books = http(path, action)["data"]
  end

  def new

  end

  def create
    path, action = 'books', 'post'
    @book = http(
      path,
      action,
      create_parameter,
    )
    render "index"
  end


  def edit; end

  def rent_book
    path = "books/#{params[:id]}/rent_book"
    action = 'patch'
    @book = http(
      path,
      action,
      rent_parameter,
    )
    redirect_to books_path
  end

  def return_book
    path = "books/#{params[:id]}/return_book"
    action = 'patch'
    @book = http(
      path,
      action,
    )
    redirect_to books_path
  end

  private

  def http(path, action, params = nil)

    uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")

    headers = { 'Authorization' => 'Bearer secret_key' }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      case action
      when 'get'
        request = Net::HTTP::Get.new(uri.request_uri, headers)
      when 'post'
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.set_form_data(params) if params
      when 'patch'
        request = Net::HTTP::Patch.new(uri.request_uri, headers)
        request.set_form_data(params) if params
      when 'delete'
        request = Net::HTTP::Delete.new(uri.request_uri, headers)
      end

      res = http.request(request)
      binding.pry

      case res
      when Net::HTTPSuccess
        JSON.parse(res.body)
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

  def create_parameter
    {
      'owner_id' => current_user.id,
      'publisher_id' => 1,
      'rent_user_id' => current_user.id,
      'purchaser_id' => current_user.id,
      'status' => '0',
      'title' => book_params["title"],
      'price' => book_params["price"],
      'author' => book_params["author"],
      'link' => book_params["link"],
      'latest_rent_date' => '',
      'return_date' => '',
      'purchase_date' => '',
      'publication_date' => '',
    }
  end

  def rent_parameter
    {
      'uid' => rent_params["uid"]
    }
  end

  def book_params
    params.permit(:title, :price, :author, :link)
  end

  def rent_params
    params.permit(:uid)
  end
end

  # def http_patch(path, uid = nil)
  #   uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
  #   headers = { 'Authorization' => 'Bearer secret_key' }
  #
  #   params = { 'uid' => uid }
  #
  #   begin
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     http.use_ssl = true
  #     http.open_timeout = 5
  #     http.read_timeout = 10
  #
  #     request = Net::HTTP::Patch.new(uri.request_uri, headers)
  #     request.set_form_data(params)
  #
  #     response = http.request(request)
  #
  #     case response
  #     when Net::HTTPSuccess
  #       JSON.parse(response.body)
  #     when Net::HTTPRedirection
  #       'redirect'
  #     else
  #       'else'
  #     end
  #
  #   rescue IOError => e
  #     logger.error(e.message)
  #   rescue TimeoutError => e
  #     logger.error(e.message)
  #   rescue JSON::ParserError => e
  #     logger.error(e.message)
  #   rescue => e
  #     logger.error(e.message)
  #   end
  # end
  #
  # def http_post(path, title, price, author, link)
  #   uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
  #   headers = { 'Authorization' => 'Bearer secret_key' }
  #
  #   params = {
  #     'owner_id' => current_user.id,
  #     'publisher_id' => 1,
  #     'rent_user_id' => current_user.id,
  #     'purchaser_id' => current_user.id,
  #     'status' => '0',
  #     'title' => title,
  #     'price' => price,
  #     'author' => author,
  #     'link' => link,
  #     'latest_rent_date' => '',
  #     'return_date' => '',
  #     'purchase_date' => '',
  #     'publication_date' => '',
  #   }
  #
  #   begin
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     http.use_ssl = true
  #     http.open_timeout = 5
  #     http.read_timeout = 10
  #
  #     request = Net::HTTP::Post.new(uri.request_uri, headers)
  #     request.set_form_data(params)
  #
  #     res = http.request(request)
  #
  #     case res
  #     when Net::HTTPSuccess
  #       JSON.parse(res.body)
  #     when Net::HTTPRedirection
  #       'redirect'
  #     else
  #       'else'
  #     end
  #
  #   rescue IOError => e
  #     logger.error(e.message)
  #   rescue TimeoutError => e
  #     logger.error(e.message)
  #   rescue JSON::ParserError => e
  #     logger.error(e.message)
  #   rescue => e
  #     logger.error(e.message)
  #   end
  # end
  #
  # def http(path)
  #   uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
  #
  #   begin
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     http.use_ssl = true
  #     http.open_timeout = 5
  #     http.read_timeout = 10
  #     headers = { 'Authorization' => 'Bearer secret_key' }
  #     res = http.get(uri.request_uri, headers)
  #
  #     case res
  #     when Net::HTTPSuccess
  #       JSON.parse(res.body)
  #     when Net::HTTPRedirection
  #     else
  #     end
  #
  #   rescue IOError => e
  #     logger.error(e.message)
  #   rescue TimeoutError => e
  #     logger.error(e.message)
  #   rescue JSON::ParserError => e
  #     logger.error(e.message)
  #   rescue => e
  #     logger.error(e.message)
  #   end
  # end
