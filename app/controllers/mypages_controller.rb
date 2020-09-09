class MypagesController < ApplicationController

  def new
    @publishers = get_publisher.map do |publisher|
      [
       publisher["publisher"],
       publisher["id"]
      ]
    end
  end

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

  def index
    path, action = "/books/#{current_user.id}/user/rent_user_books", 'get'
    @books = http(path, action)["data"]
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

  def get_publisher
    path, action = 'publishers', 'get'
    http(path, action)
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

  def predictive_search_parameter
    {
      'target' => params["target"]
    }
  end
end
