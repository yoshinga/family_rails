class BooksController < ApplicationController
  # before_action :authenticate_user!
  before_action :get_publisher, only: [:new, :new_book_search]
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    path, action = 'books', 'get'
    @books = http(path, action)["data"]
  end

  def new
    @publishers = get_publisher.map do |publisher|
      [
       publisher["publisher"],
       publisher["id"]
      ]
    end
  end

  def create
    path, action = 'books', 'post'
    @book = http(
      path,
      action,
      create_parameter,
    )
    redirect_to books_path
  end

  def get_publisher
    path, action = 'publishers', 'get'
    http(path, action)
  end

  def edit
  end

  def destroy
    path, action = "books/#{params[:id]}", 'delete'
    @book = http(
      path,
      action,
    )
    redirect_to books_path
  end

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

  def new_book_search; end

  def predictive_search
    path = "/books/predictive_search"
    action = 'post'
    response = http(
      path,
      action,
      predictive_search_parameter,
    )
    @res = check_thumbnail_present(response)
  end

  def create_book_search
    path = "/books/create_book_search"
    action = 'post'
    response = http(
      path,
      action,
      create_book_search_parameter,
    )
    # res = check_thumbnail_present(response)
    redirect_to books_path if response
  end

  private

  def check_thumbnail_present(res)
    no_img = { 'smallThumbnail'=>'https://books.google.co.jp/googlebooks/images/no_cover_thumb.gif'}
    res.each do |book|
      if book["volumeInfo"]["imageLinks"].blank?
        book["volumeInfo"].store('imageLinks', no_img)
      end
    end
  end

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
    if book_params['publisher'].present?
      publisher_key = 'publisher'
      publisher_value = book_params["publisher"]
    elsif book_params['publisher_id'].present?
      publisher_key = 'publisher_id'
      publisher_value = book_params["publisher_id"]
    end
    parameter = {
      'owner_id' => current_user.id,
      'rent_user_id' => nil,
      'purchaser_id' => current_user.id,
      'status' => '0',
      'title' => book_params["title"],
      'price' => book_params["price"],
      'author' => book_params["author"],
      'link' => book_params["link"],
      'latest_rent_date' => '',
      'return_date' => '',
      'purchase_date' => Date.today.strftime("%Y-%m-%d"),
      'publication_date' => '',
    }
    parameter.store("#{publisher_key}", "#{publisher_value}")
    return parameter
  end

  def rent_parameter
    {
      'uid' => rent_params["uid"],
      'latest_rent_date' => Date.today.strftime("%Y-%m-%d"),
    }
  end

  def predictive_search_parameter
    {
      'target' => params["target"]
    }
  end

  def create_book_search_parameter
    {
      'owner_id' => current_user.id,
      'publisher_id' => 1,
      'rent_user_id' => nil,
      'purchaser_id' => current_user.id,
      'status' => '0',
      'title' => volume_info_params[0]["title"],
      'price' => volume_info_params[2]["amount"],
      'author' => volume_info_params[1][0],
      'link' => volume_info_params[0]["infoLink"],
      'latest_rent_date' => '',
      'return_date' => '',
      'purchase_date' => Date.today.strftime("%Y-%m-%d"),
      'publication_date' => volume_info_params[0]["publishedDate"],
    }
  end

  def book_params
    params.permit(:title, :price, :author, :link, :purchase_date, :publisher_id, :publisher)
  end

  def rent_params
    params.permit(:uid)
  end

  def volume_info_params
    Array.new.push(
      params.require(:volumeInfo).permit(:title, :publisher, :publishedDate, :infoLink),
      params.require(:volumeInfo).require(:authors),
      params.require(:saleInfo).require(:listPrice).permit(:amount),
      params.require(:volumeInfo).require(:imageLinks).permit(:smallThumbnail),
    )
  end
end
