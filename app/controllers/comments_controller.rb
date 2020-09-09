class CommentsController < ApplicationController

  def create
    path, action = 'comments', 'post'
    @book = http(
      path,
      action,
      create_comment_parameter,
    )
    redirect_to book_path(params["id"])
  end

  def destroy; end

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

  def create_comment_parameter
    {
      'user_id' => comment_params["uid"],
      'book_id' => comment_params["id"],
      'content' => comment_params["content"],
    }
  end

  def comment_params
    params.permit(:content, :uid, :id)
  end
end
